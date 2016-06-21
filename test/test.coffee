#!/usr/bin/env coffee

fs = require('fs')
mdast = require('mdast')
schomd = require('../lib/schomd')
processor = mdast.use(schomd)

for source in ['pandoc', 'markdown']
  markdown = fs.readFileSync("test/#{source}.md", 'utf-8')
  fs.writeFileSync("test/#{source}.json", JSON.stringify(processor.parse(markdown), null, 2))
  fs.writeFileSync("test/#{source}.remd", processor.process(markdown))
  console.log(processor.process(markdown))
