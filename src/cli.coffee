path = require 'path'
fs = require 'fs-plus'
yargs = require 'yargs'
Highlights = require './highlights'

module.exports = ->
  argv = yargs.describe('i', 'Path to file or folder of grammars to include').alias('i', 'include').string('i')
    .describe('o', 'File path to write the HTML output to').alias('o', 'output').string('o')
    .describe('s', 'Scope name of the grammar to use').alias('s', 'scope').string('s')
    .describe('f', 'File path to use for grammar detection when reading from stdin').alias('f', 'file-path').string('f')
    .help('h').alias('h', 'help')
    .usage """
     Usage: highlights [options] [file]

     Output the syntax highlighted HTML for a file.

     If no input file is specified then the text to highlight is read from standard in.

     If no output file is specified then the HTML is written to standard out.
    """
    .version().alias('v', 'version')
    .argv

  [filePath] = argv._

  outputPath = argv.output
  outputPath = path.resolve(outputPath) if outputPath

  if filePath
    filePath = path.resolve(filePath)
    unless fs.isFileSync(filePath)
      console.error("Specified path is not a file: #{filePath}")
      process.exit(1)
      return

    html = new Highlights().highlightSync({filePath, scopeName: argv.scope})
    if outputPath
      fs.writeFileSync(outputPath, html)
    else
      console.log(html)
  else
    filePath = argv.f
    process.stdin.resume()
    process.stdin.setEncoding('utf8')
    fileContents = ''
    process.stdin.on 'data', (chunk) -> fileContents += chunk.toString()
    process.stdin.on 'end', ->
      html = new Highlights().highlightSync({filePath, fileContents, scopeName: argv.scope})
      if outputPath
        fs.writeFileSync(outputPath, html)
      else
        console.log(html)
