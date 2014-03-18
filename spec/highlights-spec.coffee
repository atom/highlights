Highlights = require '../src/highlights'

describe "Highlights", ->
  describe "highlightSync", ->
    it "returns an HTML string", ->
      highlights = new Highlights()
      html = highlights.highlightSync(fileContents: 'test')
      expect(html).toBe '<pre class="editor"><div class="line"><span class="text plain null-grammar"><span>test</span></span></div></pre>'
