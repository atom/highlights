Highlights = require '../src/highlights'

describe "Highlights", ->
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
