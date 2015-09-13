{exec} = require 'child_process'

task 'test', 'verify coffeescript', ->
  exec 'coffeelint test/*.coffee lib/*.coffee', (err, stdout, stderr) ->
    console.log stdout + stderr
    throw err if err
  exec 'coffee test/test.coffee', (err, stdout, stderr) ->
    console.log stdout + stderr
    throw err if err
