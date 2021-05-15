/* eslint-disable no-console */
declare const atom: any

// import ZoteroCitationsView from './zotero-citations-view'

// @ts-ignore
import { CompositeDisposable } from 'atom'
import fetch from 'node-fetch'

module.exports = {
  config: {
    port: {
      type: 'string',
      default: '23119',
      enum: [
        { value: '23119', description: 'Zotero'},
        { value: '24119', description: 'Juris-M'},
      ],
      title: 'Connect to',
      description: 'Choose wether to connect to Zotero or Juris-M',
    },
    citationStyle: {
      type: 'string',
      default: 'pandoc',
      enum: [
        'pandoc',
        'mmd',
        'cite',
        'citet',
        'citep',
        'LaTeX',
        { value: 'playground', description: 'citation key'},
      ],
      title: 'Citation style',
      description: 'Citation style returned by the CAYW picker',
    },
    latexCommand: {
      type: 'string',
      default: 'cite',
      title: 'LaTeX citation command',
      description: 'When the style is set to LaTeX, use this command for the returned citations',
    },
    minimize: {
      type: 'boolean',
      default: false,
      title: 'Minimize Zotero after pick',
    },
  },

  // zoteroCitationsView: null,
  // modalPanel: null,
  subscriptions: null,

  activate(_state) {
    /*
    this.zoteroCitationsView = new ZoteroCitationsView(state.zoteroCitationsViewState)
    this.modalPanel = atom.workspace.addModalPanel({
      item: this.zoteroCitationsView.getElement(),
      visible: false
    })
    */

    // Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    this.subscriptions = new CompositeDisposable()

    this.subscriptions.add(atom.commands.add('atom-workspace', {
      'zotero-citations:pick': () => { this.pick() },
    }))
  },

  deactivate() {
    // this.modalPanel.destroy()
    this.subscriptions.dispose()
    // this.zoteroCitationsView.destroy()
  },

  async pick() { // eslint-disable-line prefer-arrow/prefer-arrow-functions
    try {
      const style = atom.config.get('zotero-citations.citationStyle')
      const port = atom.config.get('zotero-citations.port')
      const cmd = atom.config.get('zotero-citations.latexCommand') || 'cite'
      const minimize = atom.config.get('zotero-citations.minimize') ? 'true' : 'false'
      const params = (style === 'LaTeX' ) ? `format=latex&command=${encodeURIComponent(cmd || 'cite')}` : `format=${encodeURIComponent(style)}`
      const url = `http://127.0.0.1:${port}/better-bibtex/cayw?${params}&minimize=${minimize}`

      console.log(`Getting ${url}`)
      const result = await (await fetch(url)).text()
      if (result) {
        const editor = atom.workspace.getActiveTextEditor()
        if (editor) editor.insertText(result)
      }
      atom.focus()
    }
    catch (err) {
      console.log(`failed to fetch citation: ${err.message}`)
      atom.focus()
      atom.notifications.addError('Zotero Citations: could not connect to Zotero. Are you sure it is running?')
    }
  },
}
