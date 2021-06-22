describe "JSX indent", ->
  fs = require 'fs'
  formattedFile = require.resolve './fixtures/sample-formatted.jsx'
  sampleFile = require.resolve './fixtures/sample.jsx'
  formattedSample = fs.readFileSync formattedFile
  formattedLines = formattedSample.toString().split '\n'
  [editor, buffer, languageMode] = []

  afterEach ->
    editor.destroy()

  beforeEach ->
    waitsForPromise ->
        atom.workspace.open(sampleFile, autoIndent: false).then (o) ->
          editor = o
          {buffer, languageMode} = editor

    waitsForPromise ->
      atom.packages.activatePackage("react")

    afterEach ->
      atom.packages.deactivatePackages()
      atom.packages.unloadPackages()

    runs ->
      grammar = atom.grammars.grammarForScopeName("source.js.jsx")
      editor.setGrammar(grammar);

  describe "should indent sample file correctly", ->
    it "autoIndentBufferRows should indent same as sample file", ->
      editor.autoIndentBufferRows(0, formattedLines.length - 1)
      for i in [0...formattedLines.length]
        line = formattedLines[i]
        continue if !line.trim()
        expect((i + 1) + ":" + buffer.lineForRow(i)).toBe ((i + 1) + ":" + line)
