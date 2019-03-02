// tslint:disable:no-console
declare const atom: any

// import ZoteroCitationsView from './zotero-citations-view'

// @ts-ignore
import { CompositeDisposable } from 'atom'

import request = require('request-promise')

module.exports = {
  config: {
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
  },

  // zoteroCitationsView: null,
  // modalPanel: null,
  subscriptions: null,

  activate(state) {
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
      'zotero-citations:pick': () => this.pick(),
    }))
  },

  deactivate() {
    // this.modalPanel.destroy()
    this.subscriptions.dispose()
    // this.zoteroCitationsView.destroy()
  },

  pick() {
    const style = atom.config.get('zotero-citations.citationStyle')
    const cmd = atom.config.get('zotero-citations.latexCommand') || 'cite'
    const params = (style === 'LaTeX' ) ? `format=latex&command=${encodeURIComponent(cmd || 'cite')}` : `format=${encodeURIComponent(style)}`
    const url = `http://127.0.0.1:23119/better-bibtex/cayw?${params}`

    console.log(`Getting ${url}`)
    request(url).then(result => {
      atom.focus()
      if (result) {
        const editor = atom.workspace.getActiveTextEditor()
        if (editor) editor.insertText(result)
      }

    }).catch(err => {
      atom.focus()
      console.log(`failed to fetch citation: ${err.message}`)
      atom.notifications.addError('Zotero Citations: could not connect to Zotero. Are you sure it is running?')

    })
  },
}
