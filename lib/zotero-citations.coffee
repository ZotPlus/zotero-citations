{CompositeDisposable} = require('atom')
#mdast = require('mdast')
#schomd = require('./schomd')
request = require('request-promise')

module.exports = ZoteroScan =
  config:
#    scanMode:
#      type: 'string'
#      default: 'markdown'
#      enum: ['markdown', 'pandoc']
#      title: 'Scan mode'
#      description: 'Scan mode: either pure-markdown, or Pandoc-compatible inline YAML'
    citationStyle:
      type: 'string'
      default: 'atom-zotero-citations'
      enum: ['atom-zotero-citations', 'pandoc', 'mmd', 'citet', 'citep']
      title: 'Citation style'
      description: 'Citation style returned by the CAYW picker'

  subscriptions: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable()
    # @subscriptions.add(atom.commands.add('atom-workspace', 'zotero-citations:scan': => @scan()))
    @subscriptions.add(atom.commands.add('atom-workspace', 'zotero-citations:pick': => @pick()))
    # @processor = mdast.use(schomd)

  deactivate:
    @subscriptions.dispose() if @subscriptions

  pick: ->
    request("http://localhost:23119/better-bibtex/cayw?format=#{atom.config.get('zotero-citations.citationStyle')}").then((result) ->
      atom.focus()
      atom.workspace.getActiveTextEditor()?.insertText(result) if result
    ).catch((err) ->
      console.log("failed to fetch bibliography: %j", err.message)
      atom.notifications.addError('Zotero Citations: could not connect to Zotero. Are you sure it is running?')
    )

#  scan: ->
#    console.log("Scanning...")
#    editor = atom.workspace.getActiveTextEditor()
#    return unless editor
#
#    markdown = editor.getText()
#    markdown = @processor.process(markdown)
#    editor.setText(markdown)
