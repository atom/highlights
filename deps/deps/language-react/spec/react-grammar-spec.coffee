TextEditor = null
buildTextEditor = (params) ->
  if atom.workspace.buildTextEditor?
    atom.workspace.buildTextEditor(params)
  else
    TextEditor ?= require('atom').TextEditor
    new TextEditor(params)

describe "React grammar", ->
  grammar = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage("language-javascript")

    waitsForPromise ->
      atom.packages.activatePackage("react")

    afterEach ->
      atom.packages.deactivatePackages()
      atom.packages.unloadPackages()

    runs ->
      grammar = atom.grammars.grammarForScopeName("source.js.jsx")

  it "parses the grammar", ->
    expect(grammar).toBeTruthy()
    expect(grammar.scopeName).toBe "source.js.jsx"

  describe "strings", ->
    it "tokenizes single-line strings", ->
      delimsByScope =
        "string.quoted.double.js": '"'
        "string.quoted.single.js": "'"

      for scope, delim of delimsByScope
        {tokens} = grammar.tokenizeLine(delim + "x" + delim)
        expect(tokens[0].value).toEqual delim
        expect(tokens[0].scopes).toEqual ["source.js.jsx", scope, "punctuation.definition.string.begin.js"]
        expect(tokens[1].value).toEqual "x"
        expect(tokens[1].scopes).toEqual ["source.js.jsx", scope]
        expect(tokens[2].value).toEqual delim
        expect(tokens[2].scopes).toEqual ["source.js.jsx", scope, "punctuation.definition.string.end.js"]

  describe "keywords", ->
    it "tokenizes with as a keyword", ->
      {tokens} = grammar.tokenizeLine('with')
      expect(tokens[0]).toEqual value: 'with', scopes: ['source.js.jsx', 'keyword.control.js']

  describe "regular expressions", ->
    it "tokenizes regular expressions", ->
      {tokens} = grammar.tokenizeLine('/test/')
      expect(tokens[0]).toEqual value: '/', scopes: ['source.js.jsx', 'string.regexp.js', 'punctuation.definition.string.begin.js']
      expect(tokens[1]).toEqual value: 'test', scopes: ['source.js.jsx', 'string.regexp.js']
      expect(tokens[2]).toEqual value: '/', scopes: ['source.js.jsx', 'string.regexp.js', 'punctuation.definition.string.end.js']

      {tokens} = grammar.tokenizeLine('foo + /test/')
      expect(tokens[0]).toEqual value: 'foo ', scopes: ['source.js.jsx']
      expect(tokens[1]).toEqual value: '+', scopes: ['source.js.jsx', 'keyword.operator.js']
      expect(tokens[2]).toEqual value: ' ', scopes: ['source.js.jsx', 'string.regexp.js']
      expect(tokens[3]).toEqual value: '/', scopes: ['source.js.jsx', 'string.regexp.js', 'punctuation.definition.string.begin.js']
      expect(tokens[4]).toEqual value: 'test', scopes: ['source.js.jsx', 'string.regexp.js']
      expect(tokens[5]).toEqual value: '/', scopes: ['source.js.jsx', 'string.regexp.js', 'punctuation.definition.string.end.js']

    it "tokenizes regular expressions inside arrays", ->
      {tokens} = grammar.tokenizeLine('[/test/]')
      expect(tokens[0]).toEqual value: '[', scopes: ['source.js.jsx', 'meta.brace.square.js']
      expect(tokens[1]).toEqual value: '/', scopes: ['source.js.jsx', 'string.regexp.js', 'punctuation.definition.string.begin.js']
      expect(tokens[2]).toEqual value: 'test', scopes: ['source.js.jsx', 'string.regexp.js']
      expect(tokens[3]).toEqual value: '/', scopes: ['source.js.jsx', 'string.regexp.js', 'punctuation.definition.string.end.js']
      expect(tokens[4]).toEqual value: ']', scopes: ['source.js.jsx', 'meta.brace.square.js']

      {tokens} = grammar.tokenizeLine('[1, /test/]')
      expect(tokens[0]).toEqual value: '[', scopes: ['source.js.jsx', 'meta.brace.square.js']
      expect(tokens[1]).toEqual value: '1', scopes: ['source.js.jsx', 'constant.numeric.decimal.js']
      expect(tokens[2]).toEqual value: ',', scopes: ['source.js.jsx', 'meta.delimiter.object.comma.js']
      expect(tokens[3]).toEqual value: ' ', scopes: ['source.js.jsx', 'string.regexp.js']
      expect(tokens[4]).toEqual value: '/', scopes: ['source.js.jsx', 'string.regexp.js', 'punctuation.definition.string.begin.js']
      expect(tokens[5]).toEqual value: 'test', scopes: ['source.js.jsx', 'string.regexp.js']
      expect(tokens[6]).toEqual value: '/', scopes: ['source.js.jsx', 'string.regexp.js', 'punctuation.definition.string.end.js']
      expect(tokens[7]).toEqual value: ']', scopes: ['source.js.jsx', 'meta.brace.square.js']

      {tokens} = grammar.tokenizeLine('0x1D306')
      expect(tokens[0]).toEqual value: '0x1D306', scopes: ['source.js.jsx', 'constant.numeric.hex.js']

      {tokens} = grammar.tokenizeLine('0X1D306')
      expect(tokens[0]).toEqual value: '0X1D306', scopes: ['source.js.jsx', 'constant.numeric.hex.js']

      {tokens} = grammar.tokenizeLine('0b011101110111010001100110')
      expect(tokens[0]).toEqual value: '0b011101110111010001100110', scopes: ['source.js.jsx', 'constant.numeric.binary.js']

      {tokens} = grammar.tokenizeLine('0B011101110111010001100110')
      expect(tokens[0]).toEqual value: '0B011101110111010001100110', scopes: ['source.js.jsx', 'constant.numeric.binary.js']

      {tokens} = grammar.tokenizeLine('0o1411')
      expect(tokens[0]).toEqual value: '0o1411', scopes: ['source.js.jsx', 'constant.numeric.octal.js']

      {tokens} = grammar.tokenizeLine('0O1411')
      expect(tokens[0]).toEqual value: '0O1411', scopes: ['source.js.jsx', 'constant.numeric.octal.js']

  describe "operators", ->
    it "tokenizes void correctly", ->
      {tokens} = grammar.tokenizeLine('void')
      expect(tokens[0]).toEqual value: 'void', scopes: ['source.js.jsx', 'keyword.operator.void.js']

    it "tokenizes the / arithmetic operator when separated by newlines", ->
      lines = grammar.tokenizeLines """
        1
        / 2
      """
      expect(lines[0][0]).toEqual value: '1', scopes: ['source.js.jsx', 'constant.numeric.decimal.js']
      expect(lines[1][0]).toEqual value: '/', scopes: ['source.js.jsx', 'keyword.operator.js']
      expect(lines[1][1]).toEqual value: ' ', scopes: ['source.js.jsx']
      expect(lines[1][2]).toEqual value: '2', scopes: ['source.js.jsx', 'constant.numeric.decimal.js']

  describe "ES6 string templates", ->
    it "tokenizes them as strings", ->
      {tokens} = grammar.tokenizeLine('`hey ${name}`')
      expect(tokens[0]).toEqual value: '`', scopes: ['source.js.jsx', 'string.quoted.template.js', 'punctuation.definition.string.begin.js']
      expect(tokens[1]).toEqual value: 'hey ', scopes: ['source.js.jsx', 'string.quoted.template.js']
      expect(tokens[2]).toEqual value: '${', scopes: ['source.js.jsx', 'string.quoted.template.js', 'source.js.embedded.source', 'punctuation.section.embedded.js']
      expect(tokens[3]).toEqual value: 'name', scopes: ['source.js.jsx', 'string.quoted.template.js', 'source.js.embedded.source']
      expect(tokens[4]).toEqual value: '}', scopes: ['source.js.jsx', 'string.quoted.template.js', 'source.js.embedded.source', 'punctuation.section.embedded.js']
      expect(tokens[5]).toEqual value: '`', scopes: ['source.js.jsx', 'string.quoted.template.js', 'punctuation.definition.string.end.js']

  describe "default: in a switch statement", ->
    it "tokenizes it as a keyword", ->
      {tokens} = grammar.tokenizeLine('default: ')
      expect(tokens[0]).toEqual value: 'default', scopes: ['source.js.jsx', 'keyword.control.js']

  it "tokenizes comments in function params", ->
    {tokens} = grammar.tokenizeLine('foo: function (/**Bar*/bar){')

    expect(tokens[5]).toEqual value: '(', scopes: ['source.js.jsx', 'meta.function.json.js', 'meta.parameters.js', 'punctuation.definition.parameters.begin.bracket.round.js']
    expect(tokens[6]).toEqual value: '/**', scopes: ['source.js.jsx', 'meta.function.json.js', 'meta.parameters.js', 'comment.block.documentation.js', 'punctuation.definition.comment.js']
    expect(tokens[7]).toEqual value: 'Bar', scopes: ['source.js.jsx', 'meta.function.json.js', 'meta.parameters.js', 'comment.block.documentation.js']
    expect(tokens[8]).toEqual value: '*/', scopes: ['source.js.jsx', 'meta.function.json.js', 'meta.parameters.js', 'comment.block.documentation.js', 'punctuation.definition.comment.js']
    expect(tokens[9]).toEqual value: 'bar', scopes: ['source.js.jsx', 'meta.function.json.js', 'meta.parameters.js', 'variable.parameter.function.js' ]

  it "tokenizes /* */ comments", ->
    {tokens} = grammar.tokenizeLine('/**/')

    expect(tokens[0]).toEqual value: '/*', scopes: ['source.js.jsx', 'comment.block.js', 'punctuation.definition.comment.js']
    expect(tokens[1]).toEqual value: '*/', scopes: ['source.js.jsx', 'comment.block.js', 'punctuation.definition.comment.js']

    {tokens} = grammar.tokenizeLine('/* foo */')

    expect(tokens[0]).toEqual value: '/*', scopes: ['source.js.jsx', 'comment.block.js', 'punctuation.definition.comment.js']
    expect(tokens[1]).toEqual value: ' foo ', scopes: ['source.js.jsx', 'comment.block.js']
    expect(tokens[2]).toEqual value: '*/', scopes: ['source.js.jsx', 'comment.block.js', 'punctuation.definition.comment.js']

  it "tokenizes /** */ comments", ->
    {tokens} = grammar.tokenizeLine('/***/')

    expect(tokens[0]).toEqual value: '/**', scopes: ['source.js.jsx', 'comment.block.documentation.js', 'punctuation.definition.comment.js']
    expect(tokens[1]).toEqual value: '*/', scopes: ['source.js.jsx', 'comment.block.documentation.js', 'punctuation.definition.comment.js']

    {tokens} = grammar.tokenizeLine('/** foo */')

    expect(tokens[0]).toEqual value: '/**', scopes: ['source.js.jsx', 'comment.block.documentation.js', 'punctuation.definition.comment.js']
    expect(tokens[1]).toEqual value: ' foo ', scopes: ['source.js.jsx', 'comment.block.documentation.js']
    expect(tokens[2]).toEqual value: '*/', scopes: ['source.js.jsx', 'comment.block.documentation.js', 'punctuation.definition.comment.js']

  it "tokenizes jsx tags", ->
    {tokens} = grammar.tokenizeLine('<tag></tag>')

    expect(tokens[0]).toEqual value: '<', scopes: ["source.js.jsx","tag.open.js","punctuation.definition.tag.begin.js"]
    expect(tokens[1]).toEqual value: 'tag', scopes: ["source.js.jsx","tag.open.js","entity.name.tag.js"]
    expect(tokens[2]).toEqual value: '>', scopes: ["source.js.jsx","tag.open.js","punctuation.definition.tag.end.js"]
    expect(tokens[3]).toEqual value: '</', scopes: ["source.js.jsx","tag.closed.js","punctuation.definition.tag.begin.js"]
    expect(tokens[4]).toEqual value: 'tag', scopes: ["source.js.jsx","tag.closed.js","entity.name.tag.js"]
    expect(tokens[5]).toEqual value: '>', scopes: ["source.js.jsx","tag.closed.js","punctuation.definition.tag.end.js"]

  it "tokenizes jsx inside parenthesis", ->
    {tokens} = grammar.tokenizeLine('return (<tag></tag>)')
    expect(tokens[3]).toEqual value: '<', scopes: ["source.js.jsx","tag.open.js","punctuation.definition.tag.begin.js"]
    expect(tokens[4]).toEqual value: 'tag', scopes: ["source.js.jsx","tag.open.js","entity.name.tag.js"]
    expect(tokens[5]).toEqual value: '>', scopes: ["source.js.jsx","tag.open.js","punctuation.definition.tag.end.js"]
    expect(tokens[6]).toEqual value: '</', scopes: ["source.js.jsx","tag.closed.js","punctuation.definition.tag.begin.js"]
    expect(tokens[7]).toEqual value: 'tag', scopes: ["source.js.jsx","tag.closed.js","entity.name.tag.js"]
    expect(tokens[8]).toEqual value: '>', scopes: ["source.js.jsx","tag.closed.js","punctuation.definition.tag.end.js"]

  it "tokenizes jsx inside function body", ->
    {tokens} = grammar.tokenizeLine('function () { return (<tag></tag>) }')
    expect(tokens[10]).toEqual value: '<', scopes: ["source.js.jsx","tag.open.js","punctuation.definition.tag.begin.js"]
    expect(tokens[11]).toEqual value: 'tag', scopes: ["source.js.jsx","tag.open.js","entity.name.tag.js"]
    expect(tokens[12]).toEqual value: '>', scopes: ["source.js.jsx","tag.open.js","punctuation.definition.tag.end.js"]
    expect(tokens[13]).toEqual value: '</', scopes: ["source.js.jsx","tag.closed.js","punctuation.definition.tag.begin.js"]
    expect(tokens[14]).toEqual value: 'tag', scopes: ["source.js.jsx","tag.closed.js","entity.name.tag.js"]
    expect(tokens[15]).toEqual value: '>', scopes: ["source.js.jsx","tag.closed.js","punctuation.definition.tag.end.js"]

  it "tokenizes jsx inside function body in an object", ->
    {tokens} = grammar.tokenizeLine('{foo:function () { return (<tag></tag>) }}')
    expect(tokens[13]).toEqual value: '<', scopes: ["source.js.jsx","tag.open.js","punctuation.definition.tag.begin.js"]
    expect(tokens[14]).toEqual value: 'tag', scopes: ["source.js.jsx","tag.open.js","entity.name.tag.js"]
    expect(tokens[15]).toEqual value: '>', scopes: ["source.js.jsx","tag.open.js","punctuation.definition.tag.end.js"]
    expect(tokens[16]).toEqual value: '</', scopes: ["source.js.jsx","tag.closed.js","punctuation.definition.tag.begin.js"]
    expect(tokens[17]).toEqual value: 'tag', scopes: ["source.js.jsx","tag.closed.js","entity.name.tag.js"]
    expect(tokens[18]).toEqual value: '>', scopes: ["source.js.jsx","tag.closed.js","punctuation.definition.tag.end.js"]


  it "tokenizes jsx inside function call", ->
    {tokens} = grammar.tokenizeLine('foo(<tag></tag>)')
    expect(tokens[2]).toEqual value: '<', scopes: ["source.js.jsx","meta.function-call.js","tag.open.js","punctuation.definition.tag.begin.js"]
    expect(tokens[3]).toEqual value: 'tag', scopes: ["source.js.jsx","meta.function-call.js","tag.open.js","entity.name.tag.js"]
    expect(tokens[4]).toEqual value: '>', scopes: ["source.js.jsx","meta.function-call.js","tag.open.js","punctuation.definition.tag.end.js"]
    expect(tokens[5]).toEqual value: '</', scopes: ["source.js.jsx","meta.function-call.js","tag.closed.js","punctuation.definition.tag.begin.js"]
    expect(tokens[6]).toEqual value: 'tag', scopes: ["source.js.jsx","meta.function-call.js","tag.closed.js","entity.name.tag.js"]
    expect(tokens[7]).toEqual value: '>', scopes: ["source.js.jsx","meta.function-call.js","tag.closed.js","punctuation.definition.tag.end.js"]

  it "tokenizes jsx inside method call", ->
    {tokens} = grammar.tokenizeLine('bar.foo(<tag></tag>)')
    expect(tokens[4]).toEqual value: '<', scopes: ["source.js.jsx","meta.method-call.js","tag.open.js","punctuation.definition.tag.begin.js"]
    expect(tokens[5]).toEqual value: 'tag', scopes: ["source.js.jsx","meta.method-call.js","tag.open.js","entity.name.tag.js"]
    expect(tokens[6]).toEqual value: '>', scopes: ["source.js.jsx","meta.method-call.js","tag.open.js","punctuation.definition.tag.end.js"]
    expect(tokens[7]).toEqual value: '</', scopes: ["source.js.jsx","meta.method-call.js","tag.closed.js","punctuation.definition.tag.begin.js"]
    expect(tokens[8]).toEqual value: 'tag', scopes: ["source.js.jsx","meta.method-call.js","tag.closed.js","entity.name.tag.js"]
    expect(tokens[9]).toEqual value: '>', scopes: ["source.js.jsx","meta.method-call.js","tag.closed.js","punctuation.definition.tag.end.js"]


  it "tokenizes ' as string inside jsx", ->
    {tokens} = grammar.tokenizeLine('<tag>fo\'o</tag>')

    expect(tokens[0]).toEqual value: '<', scopes: ["source.js.jsx","tag.open.js","punctuation.definition.tag.begin.js"]
    expect(tokens[1]).toEqual value: 'tag', scopes: ["source.js.jsx","tag.open.js","entity.name.tag.js"]
    expect(tokens[2]).toEqual value: '>', scopes: ["source.js.jsx","tag.open.js","punctuation.definition.tag.end.js"]
    expect(tokens[3]).toEqual value: 'fo\'o', scopes: ["source.js.jsx","meta.other.pcdata.js"]
    expect(tokens[4]).toEqual value: '</', scopes: ["source.js.jsx","tag.closed.js","punctuation.definition.tag.begin.js"]
    expect(tokens[5]).toEqual value: 'tag', scopes: ["source.js.jsx","tag.closed.js","entity.name.tag.js"]
    expect(tokens[6]).toEqual value: '>', scopes: ["source.js.jsx","tag.closed.js","punctuation.definition.tag.end.js"]

  it "tokenizes ternary operator inside jsx code section", ->
    {tokens} = grammar.tokenizeLine('{x?<tag></tag>:null}')
    expect(tokens[0]).toEqual value: '{', scopes: ["source.js.jsx","meta.brace.curly.js"]
    expect(tokens[1]).toEqual value: 'x', scopes: ["source.js.jsx"]
    expect(tokens[2]).toEqual value: '?', scopes: ["source.js.jsx", "keyword.operator.ternary.js"]
    expect(tokens[3]).toEqual value: '<', scopes: ["source.js.jsx","tag.open.js","punctuation.definition.tag.begin.js"]
    expect(tokens[4]).toEqual value: 'tag', scopes: ["source.js.jsx","tag.open.js","entity.name.tag.js"]
    expect(tokens[5]).toEqual value: '>', scopes: ["source.js.jsx","tag.open.js","punctuation.definition.tag.end.js"]
    expect(tokens[6]).toEqual value: '</', scopes: ["source.js.jsx","tag.closed.js","punctuation.definition.tag.begin.js"]
    expect(tokens[7]).toEqual value: 'tag', scopes: ["source.js.jsx","tag.closed.js","entity.name.tag.js"]
    expect(tokens[8]).toEqual value: '>', scopes: ["source.js.jsx","tag.closed.js","punctuation.definition.tag.end.js"]
    expect(tokens[9]).toEqual value: ':', scopes: ["source.js.jsx","keyword.operator.ternary.js"]
    expect(tokens[10]).toEqual value: 'null', scopes: ["source.js.jsx","constant.language.null.js"]
    expect(tokens[11]).toEqual value: '}', scopes: ["source.js.jsx","meta.brace.curly.js"]

    #{tokens} = grammar.tokenizeLine('<tag>\'foo</tag>')

    #expect(tokens[0]).toEqual value: '<', scopes: ["source.js.jsx","tag.open.js","punctuation.definition.tag.begin.js"]
    #expect(tokens[1]).toEqual value: 'tag', scopes: ["source.js.jsx","tag.open.js","entity.name.tag.js"]
    #expect(tokens[2]).toEqual value: '>', scopes: ["source.js.jsx","tag.open.js","punctuation.definition.tag.end.js"]
    #expect(tokens[3]).toEqual value: '\'foo', scopes: ["source.js.jsx","meta.other.pcdata.js"]
    #expect(tokens[4]).toEqual value: '</', scopes: ["source.js.jsx","tag.closed.js","punctuation.definition.tag.begin.js"]
    #expect(tokens[5]).toEqual value: 'tag', scopes: ["source.js.jsx","tag.closed.js","entity.name.tag.js"]
    #expect(tokens[6]).toEqual value: '>', scopes: ["source.js.jsx","tag.closed.js","punctuation.definition.tag.end.js"]



  describe "indentation", ->
    editor = null

    beforeEach ->
      editor = buildTextEditor()
      editor.setGrammar(grammar)

    expectPreservedIndentation = (text) ->
      editor.setText(text)
      editor.autoIndentBufferRows(0, text.split("\n").length - 1)
      expect(editor.getText()).toBe text

    it "indents allman-style curly braces", ->
      expectPreservedIndentation """
        if (true)
        {
          for (;;)
          {
            while (true)
            {
              x();
            }
          }
        }

        else
        {
          do
          {
            y();
          } while (true);
        }
      """

    it "indents non-allman-style curly braces", ->
      expectPreservedIndentation """
        if (true) {
          for (;;) {
            while (true) {
              x();
            }
          }
        } else {
          do {
            y();
          } while (true);
        }
      """
