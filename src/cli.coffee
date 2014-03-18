path = require 'path'
fs = require 'fs-plus'
optimist = require 'optimist'
Highlights = require './highlights'

module.exports = ->
  cli = optimist.describe('help', 'Show this message').alias('h', 'help')
                .describe('scope', 'Scope name of the grammar to use').alias('s', 'scopeName')
  optimist.usage """
    Usage: highlights file

    Output the syntax highlighted HTML for a file.

    If no file is specified then the text of highlight is read from standard in.
  """

  if cli.argv.help
    cli.showHelp()
    return

  [filePath] = cli.argv._
  if filePath
    filePath = path.resolve(filePath)
    unless fs.isFileSync(filePath)
      console.error("Specified path is not a file: #{filePath}")
      process.exit(1)
      return

    html = new Highlights().highlightSync({filePath, scopeName: cli.argv.scope})
    console.log(html)
  else
    process.stdin.resume()
    process.stdin.setEncoding('utf8')
    fileContents = ''
    process.stdin.on 'data', (chunk) -> fileContents += chunk.toString()
    process.stdin.on 'end', ->
      html = new Highlights().highlightSync({fileContents, scopeName: cli.argv.scope})
      console.log(html)
