class Walker
  constructor: (@processor, @ast) ->
    @citations = {}
    @cited = {}
    @request = require('sync-request')

    @inBibliography = false
    @caseInsensitive = false

    @findStyle(@ast)
    @style ?= 'apa'

    @walk(@ast)

  findStyle: (node) ->
    return unless node

    if node.type == 'definition' && node.identifier == '#citation-style'
      style = node.link.replace(/^#/, '')
      if @style && style != @style
        throw new Error("Changing style is not supported (was: #{@style}, new: #{style})")
      @style = style

    for child in node.children || []
      @findStyle(child)

  walk: (ast) ->
    return unless ast.children

    filtered = []
    for node, i in ast.children
      @inBibliography = false if node.type == 'definition' && node.identifier == '#bibliography' && node.link in ['#', '#end']

      continue if @inBibliography

      node = @["_#{node.type}"].call(@, node) if @["_#{node.type}"]
      continue unless node
      if Array.isArray(node)
        filtered = filtered.concat(node)
      else
        @walk(node)
        filtered.push(node)

      @inBibliography = true if node.type == 'definition' && node.identifier == '#bibliography' && node.link == '#start'
    ast.children = filtered

  bibliography: ->
    keys = Object.keys(@cited)
    return '' if keys.length == 0

    try
      res = @request('POST', 'http://localhost:23119/better-bibtex/schomd', {json: method: 'bibliography', params: [keys, {caseInsensitive: @caseInsensitive, style: @style}]})
      res = JSON.parse(res.getBody('utf8'))
    catch err
      res = {error: err.message}

    switch
      when res.error
        console.log("failed to fetch bibliography: %j", res.error)
        return ''

      when ! (res.result?)
        console.log("no response for bibliography")
        return ''

    return res.result

  citation: (id, caseInsensitive) ->
    return unless id
    atkeys = id.split(/\s*,\s*/)
    keys = (key.slice(1) for key in atkeys when key[0] in ['@', '#'])
    return unless atkeys.length == keys.length

    id += '/i' if caseInsensitive

    if !@citations[id]
      try
        res = @request('POST', 'http://localhost:23119/better-bibtex/schomd', {json: method: 'citation', params: [keys, {caseInsensitive, style: @style}]})
        res = JSON.parse(res.getBody('utf8'))
      catch err
        res = {error: err.message}

      switch
        when res.error
          console.log("failed to fetch #{id}: %j", res.error)
          @citations[id] = '??'

        when ! (res.result?)
          console.log("no response for #{id}")
          @citations[id] = '??'

        else
          @citations[id] = res.result || '??'

    for key in keys
      @cited[key] = true
    return @citations[id]

  _link: (ast) ->
    citation = @citation(ast.href)
    ast.children = @processor.parse(citation).children if citation
    return ast

  _linkReference: (ast) ->
    citation = @citation(ast.identifier, true)
    if citation
      ast.children = @processor.parse(citation).children
      @caseInsensitive = true
    return ast

  _definition: (ast) ->
    if ast.identifier == '#bibliography' && ast.link in ['#', '#end']
      bib = @bibliography()

      if ast.link == '#'
        bib = "[#bibliography]: #start\n" + bib
        ast.link = '#end'

      ast = @processor.parse(bib).children.concat(ast)

    return ast

module.exports = (processor) ->
  return (ast) ->
    (new Walker(processor, ast))
