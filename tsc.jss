const ts = require('typescript')
const fs = require('fs')
const glob = require('glob')

const tsconfig = require('./tsconfig.json')

for (const include of tsconfig.include) {
  for (const source of glob.sync(include)) {
    const target = source.replace(/\.[^.]+$/, '') + '.js'
    console.log(source, '=>', target)
    const js = ts.transpileModule(fs.readFileSync(source, 'utf-8'), { compilerOptions: tsconfig.compilerOptions })
    if (js.diagnostics && js.diagnostics.length) {
      console.log(js.diagnostics)
      process.exit(1)
    }
    fs.writeFileSync(target, js.outputText)
  }
}
