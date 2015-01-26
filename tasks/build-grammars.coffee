path = require 'path'
fs = require 'fs-plus'
CSON = require 'season'

module.exports = (grunt) ->
  grunt.registerTask 'build-grammars', 'Build a single file with included grammars', ->
    grammars = {}
    depsDir = path.resolve(__dirname, '..', 'deps')
    for packageDir in fs.readdirSync(depsDir)
      grammarsDir = path.join(depsDir, packageDir, 'grammars')
      continue unless fs.isDirectorySync(grammarsDir)

      for file in fs.readdirSync(grammarsDir)
        grammarPath = path.join(grammarsDir, file)
        continue unless CSON.resolve(grammarPath)
        grammar = CSON.readFileSync(grammarPath)
        grammars[grammarPath] = grammar

    grunt.file.write(path.join('gen', 'grammars.json'), JSON.stringify(grammars))
    grunt.log.ok("Wrote #{Object.keys(grammars).length} grammars to gen/grammars.json")
