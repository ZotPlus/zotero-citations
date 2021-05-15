/* eslint-disable no-console */

export default class ZoteroCitationsView {
  private element: HTMLElement

  constructor(_serializedState) {
    // Create root element
    this.element = document.createElement('div')
    this.element.classList.add('zotero-citations')

    // Create message element
    const message = document.createElement('div')
    message.textContent = 'The ZoteroCitations package is Alive! It\'s ALIVE!'
    message.classList.add('message')
    this.element.appendChild(message)
  }

  // Returns an object that can be retrieved when package is activated
  protected serialize() {
    console.log('nothing to do')
  }

  // Tear down any state and detach
  protected destroy() {
    this.element.remove()
  }

  protected getElement() {
    return this.element
  }

}
