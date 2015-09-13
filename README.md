Zotero Markdown citations
=========

This package adds Zotero support to Atom Markdown editing. To use it, you will need to have the [Better BibTeX](http://zotplus.github.io/better-bibtex/index.html) plugin installed in Zotero, and to have enabled 'Enable export by HTTP'. You also need the latest Atom version (1.0.7 at time of writing); older versions will not work, and are not supported.

After that, you can add citations to your document by including them as reference-style links to your bibtex citation key, e.g.
**\[\(Heyns, 2014\)\]\[@heyns2014\]**. You can put whatever you want in the first set of brackets (including nothing)
and the package will fill out the citation when you execute 'Zotero Citations: Scan'.

## Visual picking of citations

If you don't feel like typing
these out (and let's be honest, you don't), executing 'Zotero Citations: Pick' will call up a graphical picker which
will insert these for you, formatted and all.

**IMPORTANT**: Zotero, with Better BibTeX installed, must be running while you use these.

To generate a bibliography, add the following where you want it to appear on a line of its own:

**\[#bibliography\]: #**

The package will expand this to a full bibliography including the required fencing so it can be done again.

The default citation style is APA; if you want another style, include

**\[#citation-style\]: #cell**

(in case you want Cell) on a line of its own, *before* any citations (as the style goes into effect after this). And make sure you have the style installed in Zotero. You can get the style identifier (and style) from the [Zotero Style Repository](https://www.zotero.org/styles); the style identifier is the last part of the url of the style.

## Caveat

This is still very early work, put together over two days during christmas, you can expect there to be bugs. The real gruntwork of the citations is done by BBT, which is by now extensively tested, and this package is really not much code, but: *it edits your text*. Undo ought to work, but still. Please report any issues at https://github.com/ZotPlus/zotero-citations

