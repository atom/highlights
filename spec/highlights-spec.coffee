path = require 'path'
Highlights = require '../src/highlights'

describe "Highlights", ->
  describe "when an includePath is specified", ->
    it "includes the grammar when the path is a file", ->
      highlights = new Highlights(includePath: path.join(__dirname, 'fixtures', 'includes'))
      html = highlights.highlightSync(fileContents: 'test', scopeName: 'include1')
      expect(html).toBe '<pre class="editor editor-colors"><div class="line"><span class="include1"><span>test</span></span></div></pre>'

    it "includes the grammars when the path is a directory", ->
      highlights = new Highlights(includePath: path.join(__dirname, 'fixtures', 'includes', 'include1.cson'))
      html = highlights.highlightSync(fileContents: 'test', scopeName: 'include1')
      expect(html).toBe '<pre class="editor editor-colors"><div class="line"><span class="include1"><span>test</span></span></div></pre>'

    it "overrides built-in grammars", ->
      highlights = new Highlights(includePath: path.join(__dirname, 'fixtures', 'includes'))
      html = highlights.highlightSync(fileContents: 's = "test"', scopeName: 'source.coffee')
      expect(html).toBe '<pre class="editor editor-colors"><div class="line"><span class="source coffee"><span>s&nbsp;=&nbsp;&quot;test&quot;</span></span></div></pre>'

  describe "highlightSync", ->
    it "returns an HTML string", ->
      highlights = new Highlights()
      html = highlights.highlightSync(fileContents: 'test')
      expect(html).toBe '<pre class="editor editor-colors"><div class="line"><span class="text plain null-grammar"><span>test</span></span></div></pre>'

    it "uses the given scope name as the grammar to tokenize with", ->
      highlights = new Highlights()
      html = highlights.highlightSync(fileContents: 'test', scopeName: 'source.coffee')
      expect(html).toBe '<pre class="editor editor-colors"><div class="line"><span class="source coffee"><span>test</span></span></div></pre>'

    it "uses the best grammar match when no scope name is specified", ->
      highlights = new Highlights()
      html = highlights.highlightSync(fileContents: 'test', filePath: 'test.coffee')
      expect(html).toBe '<pre class="editor editor-colors"><div class="line"><span class="source coffee"><span>test</span></span></div></pre>'

  describe "requireGrammarsSync", ->
    it "loads a grammar from an npm module", ->
      highlights = new Highlights()
      highlights.requireGrammarsSync(modulePath: require.resolve('atom-language-clojure/package.json'))
      html = highlights.highlightSync(fileContents: '(def ^:dynamic chunk-size 17)', scopeName: 'source.clojure')
      expect(html).toContain '<span class="meta expression clojure">'

    it "loads default grammars prior to loading grammar from module", ->
      highlights = new Highlights()
      highlights.requireGrammarsSync(modulePath: require.resolve('atom-language-clojure/package.json'))
      html = highlights.highlightSync(fileContents: 'test', scopeName: 'source.coffee')
      expect(html).toBe '<pre class="editor editor-colors"><div class="line"><span class="source coffee"><span>test</span></span></div></pre>'
