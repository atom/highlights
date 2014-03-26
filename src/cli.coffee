path = require 'path'
fs = require 'fs-plus'
optimist = require 'optimist'
Highlights = require './highlights'

module.exports = ->
  cli = optimist.describe('h', 'Show this message').alias('h', 'help')
                .describe('i', 'Path to file or folder of grammars to include').alias('i', 'include').string('i')
                .describe('o', 'File path to write the HTML output to').alias('o', 'output').string('o')
                .describe('s', 'Scope name of the grammar to use').alias('s', 'scope').string('s')
                .describe('v', 'Output the version').alias('v', 'version').boolean('s')
  optimist.usage """
    Usage: highlights [options] [file]

    Output the syntax highlighted HTML for a file.

    If no input file is specified then the text to highlight is read from standard in.

    If no output file is specified then the HTML is written to standard out.
  """

  if cli.argv.help
    cli.showHelp()
    return

  if cli.argv.version
    {version} = require '../package.json'
    console.log(version)
    return

  [filePath] = cli.argv._
  if filePath
    filePath = path.resolve(filePath)
    unless fs.isFileSync(filePath)
      console.error("Specified path is not a file: #{filePath}")
      process.exit(1)
      return

    html = new Highlights().highlightSync({filePath, scopeName: cli.argv.scope})
    if cli.argv.output
      outputPath = path.resolve(cli.argv.output)
      fs.writeFileSync(outputPath, html)
    else
      console.log(html)
  else
    process.stdin.resume()
    process.stdin.setEncoding('utf8')
    fileContents = ''
    process.stdin.on 'data', (chunk) -> fileContents += chunk.toString()
    process.stdin.on 'end', ->
      html = new Highlights().highlightSync({fileContents, scopeName: cli.argv.scope})
      console.log(html)
