"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
class ZoteroCitationsView {
    constructor(_serializedState) {
        this.element = document.createElement('div');
        this.element.classList.add('zotero-citations');
        const message = document.createElement('div');
        message.textContent = 'The ZoteroCitations package is Alive! It\'s ALIVE!';
        message.classList.add('message');
        this.element.appendChild(message);
    }
    serialize() {
        console.log('nothing to do');
    }
    destroy() {
        this.element.remove();
    }
    getElement() {
        return this.element;
    }
}
exports.default = ZoteroCitationsView;
