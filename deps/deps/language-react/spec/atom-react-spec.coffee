describe "React tests", ->
  sampleCorrectFile = require.resolve './fixtures/sample-correct.js'
  sampleCorrectNativeFile = require.resolve './fixtures/sample-correct-native.js'
  sampleCorrectES6File = require.resolve './fixtures/sample-correct-es6.js'
  sampleCorrectAddonsES6File = require.resolve './fixtures/sample-correct-addons-es6.js'
  sampleCorrectAddonsFile = require.resolve './fixtures/sample-correct-addons.js'
  sampleInvalidFile = require.resolve './fixtures/sample-invalid.js'

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage("language-javascript")

    waitsForPromise ->
      atom.packages.activatePackage("react")

    afterEach ->
      atom.packages.deactivatePackages()
      atom.packages.unloadPackages()

  describe "should select correct grammar", ->
    it "should select source.js.jsx if file has require('react')", ->
      waitsForPromise ->
        atom.workspace.open(sampleCorrectFile, autoIndent: false).then (editor) ->
          expect(editor.getGrammar().scopeName).toEqual 'source.js.jsx'
          editor.destroy()

    it "should select source.js.jsx if file has require('react-native')", ->
      waitsForPromise ->
        atom.workspace.open(sampleCorrectNativeFile, autoIndent: false).then (editor) ->
          expect(editor.getGrammar().scopeName).toEqual 'source.js.jsx'
          editor.destroy()

    it "should select source.js.jsx if file has require('react/addons')", ->
      waitsForPromise ->
        atom.workspace.open(sampleCorrectAddonsFile, autoIndent: false).then (editor) ->
          expect(editor.getGrammar().scopeName).toEqual 'source.js.jsx'
          editor.destroy()

    it "should select source.js.jsx if file has react es6 import", ->
      waitsForPromise ->
        atom.workspace.open(sampleCorrectES6File, autoIndent: false).then (editor) ->
          expect(editor.getGrammar().scopeName).toEqual 'source.js.jsx'
          editor.destroy()

    it "should select source.js.jsx if file has react/addons es6 import", ->
      waitsForPromise ->
        atom.workspace.open(sampleCorrectAddonsES6File, autoIndent: false).then (editor) ->
          expect(editor.getGrammar().scopeName).toEqual 'source.js.jsx'
          editor.destroy()

    it "should select source.js if file doesnt have require('react')", ->
      waitsForPromise ->
        atom.workspace.open(sampleInvalidFile, autoIndent: false).then (editor) ->
          expect(editor.getGrammar().scopeName).toEqual 'source.js'
          editor.destroy()
