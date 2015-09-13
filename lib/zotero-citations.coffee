{CompositeDisposable} = require('atom')
mdast = require('mdast')
schomd = require('./schomd')

module.exports = ZoteroScan =
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
    #req.open('GET', 'http://localhost:23119/better-bibtex/cayw?format=atom-zotero-citations&minimize=true', false)
    req.open('GET', 'http://localhost:23119/better-bibtex/cayw?format=atom-zotero-citations', false)
    req.send(null)

    atom.workspace.getActiveTextEditor()?.insertText(req.responseText) if req.status == 200 && req.responseText

  scan: ->
    console.log("Scanning...")
    editor = atom.workspace.getActiveTextEditor()
    return unless editor

    markdown = editor.getText()
    markdown = @processor.process(markdown)
    editor.setText(markdown)
