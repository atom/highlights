describe 'Coffee-React grammar', ->
  grammar = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage('language-coffee-script')
    waitsForPromise ->
      atom.packages.activatePackage('react')

    runs ->
      grammar = atom.grammars.grammarForScopeName('source.coffee.jsx')

  it 'parses the grammar', ->
    expect(grammar).toBeTruthy()
    expect(grammar.scopeName).toBe 'source.coffee.jsx'

  it 'tokenizes CoffeeScript', ->
    {tokens} = grammar.tokenizeLine('foo = @bar')

    expect(tokens.length).toEqual 5

    expect(tokens[0]).toEqual
      value: 'foo'
      scopes: [
        'source.coffee.jsx'
        'variable.assignment.coffee'
      ]
    expect(tokens[1]).toEqual
      value: ' '
      scopes: [
        'source.coffee.jsx'
      ]
    expect(tokens[2]).toEqual
      value: '='
      scopes: [
        'source.coffee.jsx'
        'keyword.operator.coffee'
      ]
    expect(tokens[3]).toEqual
      value: ' '
      scopes: [
        'source.coffee.jsx'
      ]
    expect(tokens[4]).toEqual
      value: '@bar'
      scopes: [
        'source.coffee.jsx'
        'variable.other.readwrite.instance.coffee'
      ]

  describe 'CJSX', ->

    it 'tokenizes CJSX', ->
      {tokens} = grammar.tokenizeLine '<div>hi</div>'

      expect(tokens.length).toEqual 7

      expect(tokens[0]).toEqual
        value: '<'
        scopes: [
          'source.coffee.jsx'
          'meta.tag.other.html'
          'punctuation.definition.tag.begin.html'
        ]
      expect(tokens[1]).toEqual
        value: 'div'
        scopes: [
          'source.coffee.jsx'
          'meta.tag.other.html'
          'entity.name.tag.other.html'
        ]
      expect(tokens[2]).toEqual
        value: '>'
        scopes: [
          'source.coffee.jsx'
          'meta.tag.other.html'
          'punctuation.definition.tag.end.html'
        ]
      expect(tokens[3]).toEqual
        value: 'hi'
        scopes: [
          'source.coffee.jsx'
        ]
      expect(tokens[4]).toEqual
        value: '<'
        scopes: [
          'source.coffee.jsx'
          'meta.tag.other.html'
          'punctuation.definition.tag.begin.html'
        ]
      expect(tokens[5]).toEqual
        value: '/div'
        scopes: [
          'source.coffee.jsx'
          'meta.tag.other.html'
          'entity.name.tag.other.html'
        ]
      expect(tokens[6]).toEqual
        value: '>'
        scopes: [
          'source.coffee.jsx'
          'meta.tag.other.html'
          'punctuation.definition.tag.end.html'
        ]

    it 'tokenizes props', ->
      {tokens} = grammar.tokenizeLine '<div className="span6"></div>'

      expect(tokens.length).toEqual 12

      expect(tokens[2]).toEqual
        value: ' '
        scopes: [
          'source.coffee.jsx'
          'meta.tag.other.html'
        ]
      expect(tokens[3]).toEqual
        value: 'className'
        scopes: [
          'source.coffee.jsx'
          'meta.tag.other.html'
          'entity.other.attribute-name.html'
        ]
      expect(tokens[4]).toEqual
        value: '='
        scopes: [
          'source.coffee.jsx'
          'meta.tag.other.html'
        ]
      expect(tokens[5]).toEqual
        value: '"'
        scopes: [
          'source.coffee.jsx'
          'meta.tag.other.html'
          'string.quoted.double.html'
          'punctuation.definition.string.begin.html'
        ]
      expect(tokens[6]).toEqual
        value: 'span6'
        scopes: [
          'source.coffee.jsx'
          'meta.tag.other.html'
          'string.quoted.double.html'
        ]
      expect(tokens[7]).toEqual
        value: '"'
        scopes: [
          'source.coffee.jsx'
          'meta.tag.other.html'
          'string.quoted.double.html'
          'punctuation.definition.string.end.html'
        ]

    it 'tokenizes props with digits', ->
      {tokens} = grammar.tokenizeLine '<div thing1="hi"></div>'

      expect(tokens[3]).toEqual
        value: 'thing1'
        scopes: [
          'source.coffee.jsx'
          'meta.tag.other.html'
          'entity.other.attribute-name.html'
        ]

    it 'tokenizes interpolated CoffeeScript strings', ->
      {tokens} = grammar.tokenizeLine '<div className="#{@var}"></div>'

      expect(tokens.length).toEqual 14

      expect(tokens[6]).toEqual
        value: '#{'
        scopes: [
          'source.coffee.jsx'
          'meta.tag.other.html'
          'string.quoted.double.html'
          'source.coffee.embedded.source'
          'punctuation.section.embedded.coffee'
        ]
      expect(tokens[7]).toEqual
        value: '@var'
        scopes: [
          'source.coffee.jsx'
          'meta.tag.other.html'
          'string.quoted.double.html'
          'source.coffee.embedded.source'
          'variable.other.readwrite.instance.coffee'
        ]
      expect(tokens[8]).toEqual
        value: '}'
        scopes: [
          'source.coffee.jsx'
          'meta.tag.other.html'
          'string.quoted.double.html'
          'source.coffee.embedded.source'
          'punctuation.section.embedded.coffee'
        ]

    it 'tokenizes embedded CoffeeScript', ->
      {tokens} = grammar.tokenizeLine '<div>{@var}</div>'

      expect(tokens.length).toEqual 9

      expect(tokens[3]).toEqual
        value: '{'
        scopes: [
          'source.coffee.jsx'
          'meta.brace.curly.coffee'
        ]
      expect(tokens[4]).toEqual
        value: '@var'
        scopes: [
          'source.coffee.jsx'
          'variable.other.readwrite.instance.coffee'
        ]
      expect(tokens[5]).toEqual
        value: '}'
        scopes: [
          'source.coffee.jsx'
          'meta.brace.curly.coffee'
        ]

    it "doesn't tokenize inner CJSX as CoffeeScript", ->
      {tokens} = grammar.tokenizeLine "<div>it's and</div>"

      expect(tokens.length).toEqual 7

      expect(tokens[3]).toEqual
        value: "it's and"
        scopes: [
          'source.coffee.jsx'
        ]
