#!/usr/bin/env coffee

fs = require('fs')
mdast = require('mdast')
schomd = require('../lib/schomd')

markdown = fs.readFileSync('test/test.md', 'utf-8')
#processor = mdast.use(schomd)
processor = mdast
fs.writeFileSync('test/test.json', JSON.stringify(processor.parse(markdown), null, 2))
fs.writeFileSync('test/test.remd', processor.process(markdown))
