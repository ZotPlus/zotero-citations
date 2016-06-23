yaml = require('js-yaml')
deasync = require('deasync')
request = require('request')

# debug
if not atom
  console.log('atom not defined, instantiating debug stubs')
  atom =
    notifications:
      addError: (msg) -> console.log('addError:', msg)
    config:
      get: (pref) ->
        switch pref
          when 'zotero-citations.scanMode' then 'markdown'
          else throw new Error("Unsupported debug pref #{pref}")

class Walker
  constructor: (@processor, @ast) ->
    @mode = atom.config.get('zotero-citations.scanMode')
    @citations = {keys: []}
    @cited = {}

    @scan(@ast)
    @style ?= 'apa'

    try
      if @citations.keys.length > 0
        @citations.labels = @remote('citations', [@citations.keys, {style: @style}])
      else
        @citations.labels = []
      for label, i in @citations.labels
        continue if label
        atom.notifications.addError("No citation found for #{@citations.keys[i].join(',')}")
    catch err
      console.log("failed to fetch citations: %j", err)
      atom.notifications.addError('Zotero Citations: could not connect to Zotero. Are you sure it is running?')
      return

    @inBibliography = false
    @process(@ast)

  scan: (node) ->
    return unless node

    keys = []
    switch node.type
      when 'link'
        keys = m[2].split(',') if @mode == 'markdown' && node.href && m = node.href.match(/^(\?|#)@(.*)/)

      when 'linkReference'
        if @mode == 'pandoc' && node.identifier && node.identifier.match(/^@/)
          keys = node.identifier.split(',')
          if keys.every((key) -> key[0] == '@')
            keys = (key.substr(1) for key in keys)
          else
            keys = []

      when 'text'
        if @mode == 'pandoc' && node.value
          node.value.replace(/@([^\s\n,;@]+)/g, (match, key) -> keys.push(key))

      when 'definition'
        if node.identifier == '#citation-style'
          style = node.link.replace(/^#/, '')
          if @style && style != @style
            throw new Error("Changing style is not supported (was: #{@style}, new: #{style})")
          @style = style

    if keys.length > 0
      @citations.keys.push(keys)
      node.citation = @citations.keys.length
      for key in keys
        @cited[key] = true

    for child in node.children || []
      @scan(child)

  bibEnd: (node) -> node.type == 'definition' && node.identifier == '#bibliography' && node.link in ['#', '#end']

  process: (ast) ->
    return unless ast.children

    if @mode == 'pandoc'
      keys = Object.keys(@cited)
      if keys.length == 0
        atom.notifications.addError('Zotero Citations: no pandoc citations found')
        return

      node = ast.children.find((node) -> node.type == 'yaml')
      if !node
        atom.notifications.addError('Zotero Citations: no pandoc YAML header found')
        return
      header = yaml.safeLoad(node.value)
      try
        bib = yaml.safeLoad(@remote('bibliography', [keys, {format: 'yaml'}]))
        header.references = bib.references
        node.value = yaml.safeDump(header)
      catch
        atom.notifications.addError('Zotero Citations: could not connect to Zotero. Are you sure it is running?')
      return

    filtered = []
    for node, i in ast.children
      @inBibliography = false if @bibEnd(node)

      continue if @inBibliography

      if node.citation
        node.children = @processor.parse(@citations.labels[node.citation - 1] || '??').children
        filtered.push(node)
        continue

      if @bibEnd(node)
        bib = @bibliography()

        if node.link == '#'
          bib = "[#bibliography]: #start\n" + bib
          node.link = '#end'

        node = @processor.parse(bib).children.concat(node)

      if Array.isArray(node)
        filtered = filtered.concat(node)
      else
        @process(node)
        filtered.push(node)

      @inBibliography = true if node.type == 'definition' && node.identifier == '#bibliography' && node.link == '#start'
    ast.children = filtered

  bibliography: ->
    keys = Object.keys(@cited)
    return '' if keys.length == 0

    try
      bib = @remote('bibliography', [keys, {caseInsensitive: @caseInsensitive, style: @style}])
    catch err
      console.log("failed to fetch bibliography: %j", err.message)
      atom.notifications.addError('Zotero Citations: could not connect to Zotero. Are you sure it is running?')
      return ''

    if !bib
      console.log("no response for bibliography")
      return ''

    return bib

  remote: (method, params) ->
    try
      res = @post(method, params)
    catch err
      res = {error: err.message}

    if res.error
      console.log(res.error)
      throw new Error(res.error)
    return res.result

if typeof XMLHttpRequest == 'undefined'
  Walker::post = (method, params) ->
    status = {}
    request({
      url: 'http://localhost:23119/better-bibtex/schomd'
      method: 'POST'
      json: true
      body: {method, params}
    }, (error, response, body) ->
      status.error = error
      status.body = body
      status.done = true
    )
    require('deasync').runLoopOnce() while !status.done
    throw status.error if status.error
    return status.body

else
  Walker::post = (method, params) ->
    client = new XMLHttpRequest()
    client.open('POST', 'http://localhost:23119/better-bibtex/schomd', false)
    client.send(JSON.stringify({method, params}))
    return JSON.parse(client.responseText)

module.exports = (processor) ->
  return (ast) ->
    (new Walker(processor, ast))
