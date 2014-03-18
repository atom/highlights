path = require 'path'
fs = require 'fs-plus'
optimist = require 'optimist'
Highlights = require './highlights'

module.exports = ->
  cli = optimist.describe('help', 'Show this message').alias('h', 'help')
                .describe('scope', 'Scope name of grammar to use').alias('s', 'scopeName')
  optimist.usage """
    Usage: highlights file

    Output the syntax highlighted HTML for a file.
  """


  if cli.argv.help
    cli.showHelp()
    return

  [filePath] = cli.argv._
  unless filePath
    console.error('Missing required file path to highlight')
    process.exit(1)
    return

  filePath = path.resolve(filePath)
  unless fs.isFileSync(filePath)
    console.error("Specified path is not a file: #{filePath}")
    process.exit(1)
    return

  html = new Highlights().highlightFileSync(filePath, cli.argv.scope)
  console.log(html)
