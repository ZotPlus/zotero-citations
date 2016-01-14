{CompositeDisposable} = require('atom')
mdast = require('mdast')
schomd = require('./schomd')

module.exports = ZoteroScan =
  config:
    scanMode:
      type: 'string'
      default: 'markdown'
      enum: ['markdown', 'pandoc']
      title: 'Scan mode'
      description: 'Scan mode: either pure-markdown, or Pandoc-compatible inline YAML'
    citationStyle:
      type: 'string'
      default: 'atom-zotero-citations'
      enum: ['atom-zotero-citations', 'pandoc', 'mmd', 'citet', 'citep']
      title: 'Citation style'
      description: 'Citation style returned by the CAYW picker'

  subscriptions: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable()
    @subscriptions.add(atom.commands.add('atom-workspace', 'zotero-citations:scan': => @scan()))
    @subscriptions.add(atom.commands.add('atom-workspace', 'zotero-citations:pick': => @pick()))
    @processor = mdast.use(schomd)

  deactivate:
    @subscriptions.dispose() if @subscriptions

  pick: ->
    req = new XMLHttpRequest()
    req.open('GET', "http://localhost:23119/better-bibtex/cayw?format=#{atom.config.get('zotero-citations.citationStyle')}", true)
    req.onload = (e) ->
      if req.readyState == 4
        if req.status == 200
          atom.workspace.getActiveTextEditor()?.insertText(req.responseText) if req.responseText
        else
          console.error(req.statusText)
        atom.focus()

    req.onerror = (e) ->
      console.error(req.statusText)
      atom.focus()

    req.send(null)


  scan: ->
    console.log("Scanning...")
    editor = atom.workspace.getActiveTextEditor()
    return unless editor

    markdown = editor.getText()
    markdown = @processor.process(markdown)
    editor.setText(markdown)
