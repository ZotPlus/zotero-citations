{CompositeDisposable} = require('atom')
request = require('request-promise')

module.exports = ZoteroScan =
  config:
    citationStyle:
      type: 'string'
      default: 'pandoc'
      enum: ['pandoc', 'mmd', 'citet', 'citep']
      title: 'Citation style'
      description: 'Citation style returned by the CAYW picker'

  subscriptions: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable()
    @subscriptions.add(atom.commands.add('atom-workspace', 'zotero-citations:pick': => @pick()))

  deactivate:
    @subscriptions.dispose() if @subscriptions

  pick: ->
    console.log("Getting %j", "http://127.0.0.1:23119/better-bibtex/cayw?format=#{atom.config.get('zotero-citations.citationStyle')}")
    request("http://127.0.0.1:23119/better-bibtex/cayw?format=#{atom.config.get('zotero-citations.citationStyle')}").then((result) ->
      atom.focus()
      atom.workspace.getActiveTextEditor()?.insertText(result) if result
    ).catch((err) ->
      console.log("failed to fetch citation: %j", err.message)
      atom.notifications.addError('Zotero Citations: could not connect to Zotero. Are you sure it is running?')
    )
