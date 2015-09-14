class Walker
  constructor: (@processor, @ast) ->
    @citations = []
    @cited = {}

    @XMLHttpRequest = (typeof XMLHttpRequest != 'undefined')

    @scan(@ast)
    @style ?= 'apa'

    @citations = @remote('citations', [@citations, {style: @style}]) if @citations.length > 0

    @inBibliography = false
    @process(@ast)

  remote: (method, params) ->
    if @XMLHttpRequest
      client = new XMLHttpRequest()
      req = JSON.stringify({method, params})
      client.open('POST', 'http://localhost:23119/better-bibtex/schomd', false)
      client.send(req)

      try
        res = JSON.parse(client.responseText)
      catch err
        res = {error: err.message}

    else
      @request ?= require('sync-request')
      try
        res = @request('POST', 'http://localhost:23119/better-bibtex/schomd', {json: {method, params}})
        res = JSON.parse(res.getBody('utf8'))
      catch err
        res = {error: err.message}

    console.log(res.error)
    throw new Error(res.error) if res.error
    return res.result

  scan: (node) ->
    return unless node

    keys = []
    switch node.type
      when 'link'
        keys = @keys(node.href)

      when 'linkReference'
        keys = @keys(node.identifier)

      when 'definition'
        if node.identifier == '#citation-style'
          style = node.link.replace(/^#/, '')
          if @style && style != @style
            throw new Error("Changing style is not supported (was: #{@style}, new: #{style})")
          @style = style

    if keys.length > 0
      @citations.push(keys)
      node.citation = @citations.length
      for key in keys
        @cited[key] = true

    for child in node.children || []
      @scan(child)

  bibEnd: (node) -> node.type == 'definition' && node.identifier == '#bibliography' && node.link in ['#', '#end']

  process: (ast) ->
    return unless ast.children

    filtered = []
    for node, i in ast.children
      @inBibliography = false if @bibEnd(node)

      continue if @inBibliography

      if node.citation
        node.children = @processor.parse(@citations[node.citation - 1] || '??').children
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
      return ''

    if !bib
      console.log("no response for bibliography")
      return ''

    return bib

  keys: (id) ->
    return [] unless id
    atkeys = id.split(/\s*,\s*/)
    keys = (key.slice(1) for key in atkeys when key[0] in ['@', '#'])
    return keys if atkeys.length == keys.length
    return []

module.exports = (processor) ->
  return (ast) ->
    (new Walker(processor, ast))
