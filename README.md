Zotero Markdown citations
=========

This package adds Zotero support to Atom Markdown editing. To use it, you will need to have the [Better BibTeX](http://zotplus.github.io/better-bibtex/index.html) plugin installed in Zotero. If using Zotero for Firefox, you also need to enable `Enable export by HTTP` in the `Better BibTeX` tab of the Zotero preferences. You also need the latest Atom version (1.0.7 at time of writing); older versions are not supported and may not work.

After that, you can add citations to your document by including them as reference-style links to your bibtex citation key, e.g.
**\[\(Heyns, 2014\)\]\[@heyns2014\]** or **\[\(Heyns, 2014\)\]\(#heyns2014\)**. You can put whatever you want in the first set of brackets (including nothing)
and the package will fill out the citation when you execute 'Zotero Citations: Scan'.


The two forms of in-text citations both have their pros and cons:

* Definition-style links (\[\(Heyns, 2014\)\]\[@heyns2014\]) show the reference title when you hover over the rendered
  HTML version (the title will be in the "title" attribute of the generated hyperlink), but since it is technically a label,
  the [commonmark spec](http://spec.commonmark.org/0.22/#matches) says it needs to be case-folded, so you can only use
  this form if your citekeys are lowercase ascii.
* Regular links (\[\(Heyns, 2014\)\]\(#heyns2014\)) do not have this lowercase-ascii limitation, but they do not include
  the "title" attribute in the generated link. This 'works' because such links are in fact internal anchors in an HTML
  document; if you actually want to use internal anchors in your document and not have this plugin mess with them,
  disable "parse anchor links" in the options.

## Visual picking of citations

If you don't feel like typing
these out (and let's be honest, you don't), executing 'Zotero Citations: Pick' will call up a graphical picker which
will insert these for you, formatted and all.

**IMPORTANT**: Zotero, with Better BibTeX installed, must be running while you use these.

To generate a bibliography, add the following where you want it to appear on a line of its own: **\[#bibliography\]: #**

The package will expand this to a full bibliography including the required fencing so it can be done again. The expanded
version will have the bibliography surrounded with **\[#bibliography\]: #start** and **\[#bibliography\]: #end**.

The default citation style is APA; if you want another style, include **\[#citation-style\]: #cell** (in case you want Cell) on a line of its own. And make sure you have the style installed in Zotero. You can get the style identifier (and style) from the [Zotero Style Repository](https://www.zotero.org/styles); the style identifier is the last part of the url of the style.

You can also use the picker for MultiMarkdown or Pandoc citations; you can choose between the desired format in the package config. Not that of the three formats available, only `atom-zotero-citations` will work with the `scan` command.

## Caveat -- DO READ

This is still very early work, put together over two days during christmas. The first thing to stress is this:

**this plugin will actively change your text**

In the good case, it will change only those parts you want, but I cannot guarantee this; the plugin will parse your
markdown source using [mdast](https://github.com/wooorm/mdast), replace the magic links it finds in the parsed
structure, and turn the parsed markdown back into text using mdast. This transformation using mdast is *semantically,
but not literally* lossless. It will, for example, merrily parse lists with items marked with `*`, but it will always
output lists that are marked with `-`.  There's nothing I can do about this short of writing my own markdown parser,
which is not on the table.

Undo ought to work, but I cannot stress this enough: It will modify your text. I am not wholly comfortable doing this,
but it's the only way I knew how to do pure-markdown citations.

Please report any issues at https://github.com/ZotPlus/zotero-citations

