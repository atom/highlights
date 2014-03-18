path = require 'path'
optimist = require 'optimist'
Highlights = require './highlights'

module.exports = ->
  cli = optimist.describe('help', 'Show this message').alias('h', 'help')
                .demand(1)
  optimist.usage """
    Usage: highlights file

    Output the syntax highlighted HTML for a file.
  """


  if cli.argv.help
    cli.showHelp()
    return

  [filePath] = cli.argv._
  filePath = path.resolve(filePath)

  html = new Highlights().highlightFileSync(filePath)
  console.log(html)
