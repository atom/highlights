describe "Ruby grammar", ->
  grammar = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage("language-ruby")

    runs ->
      grammar = atom.grammars.grammarForScopeName("source.ruby")

  it "parses the grammar", ->
    expect(grammar).toBeTruthy()
    expect(grammar.scopeName).toBe "source.ruby"

  it "tokenizes self", ->
    {tokens} = grammar.tokenizeLine('self')
    expect(tokens[0]).toEqual value: 'self', scopes: ['source.ruby', 'variable.language.self.ruby']

  it "tokenizes symbols", ->
    {tokens} = grammar.tokenizeLine(':test')
    expect(tokens[0]).toEqual value: ':', scopes: ['source.ruby', 'constant.other.symbol.ruby', 'punctuation.definition.constant.ruby']
    expect(tokens[1]).toEqual value: 'test', scopes: ['source.ruby', 'constant.other.symbol.ruby']

    {tokens} = grammar.tokenizeLine(':$symbol')
    expect(tokens[0]).toEqual value: ':', scopes: ['source.ruby', 'constant.other.symbol.ruby', 'punctuation.definition.constant.ruby']
    expect(tokens[1]).toEqual value: '$symbol', scopes: ['source.ruby', 'constant.other.symbol.ruby']

  it "tokenizes %{} style strings", ->
    {tokens} = grammar.tokenizeLine('%{te{s}t}')

    expect(tokens[0]).toEqual value: '%{', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby', 'punctuation.definition.string.begin.ruby']
    expect(tokens[1]).toEqual value: 'te', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby']
    expect(tokens[2]).toEqual value: '{', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby', 'punctuation.section.scope.ruby']
    expect(tokens[3]).toEqual value: 's', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby']
    expect(tokens[4]).toEqual value: '}', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby', 'punctuation.section.scope.ruby']
    expect(tokens[5]).toEqual value: 't', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby']
    expect(tokens[6]).toEqual value: '}', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby', 'punctuation.definition.string.end.ruby']

  it "tokenizes %() style strings", ->
    {tokens} = grammar.tokenizeLine('%(te(s)t)')

    expect(tokens[0]).toEqual value: '%(', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby', 'punctuation.definition.string.begin.ruby']
    expect(tokens[1]).toEqual value: 'te', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby']
    expect(tokens[2]).toEqual value: '(', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby', 'punctuation.section.scope.ruby']
    expect(tokens[3]).toEqual value: 's', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby']
    expect(tokens[4]).toEqual value: ')', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby', 'punctuation.section.scope.ruby']
    expect(tokens[5]).toEqual value: 't', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby']
    expect(tokens[6]).toEqual value: ')', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby', 'punctuation.definition.string.end.ruby']

  it "tokenizes %[] style strings", ->
    {tokens} = grammar.tokenizeLine('%[te[s]t]')

    expect(tokens[0]).toEqual value: '%[', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby', 'punctuation.definition.string.begin.ruby']
    expect(tokens[1]).toEqual value: 'te', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby']
    expect(tokens[2]).toEqual value: '[', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby', 'punctuation.section.scope.ruby']
    expect(tokens[3]).toEqual value: 's', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby']
    expect(tokens[4]).toEqual value: ']', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby', 'punctuation.section.scope.ruby']
    expect(tokens[5]).toEqual value: 't', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby']
    expect(tokens[6]).toEqual value: ']', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby', 'punctuation.definition.string.end.ruby']

  it "tokenizes %<> style strings", ->
    {tokens} = grammar.tokenizeLine('%<te<s>t>')

    expect(tokens[0]).toEqual value: '%<', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby', 'punctuation.definition.string.begin.ruby']
    expect(tokens[1]).toEqual value: 'te', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby']
    expect(tokens[2]).toEqual value: '<', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby', 'punctuation.section.scope.ruby']
    expect(tokens[3]).toEqual value: 's', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby']
    expect(tokens[4]).toEqual value: '>', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby', 'punctuation.section.scope.ruby']
    expect(tokens[5]).toEqual value: 't', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby']
    expect(tokens[6]).toEqual value: '>', scopes: ['source.ruby', 'string.quoted.other.interpolated.ruby', 'punctuation.definition.string.end.ruby']

  it "tokenizes regular expressions", ->
    {tokens} = grammar.tokenizeLine('/test/')

    expect(tokens[0]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[1]).toEqual value: 'test', scopes: ['source.ruby', 'string.regexp.interpolated.ruby']
    expect(tokens[2]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']

    {tokens} = grammar.tokenizeLine('/{w}/')

    expect(tokens[0]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[1]).toEqual value: '{w}', scopes: ['source.ruby', 'string.regexp.interpolated.ruby']
    expect(tokens[2]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']

    {tokens} = grammar.tokenizeLine('a_method /test/')

    expect(tokens[0]).toEqual value: 'a_method ', scopes: ['source.ruby']
    expect(tokens[1]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[2]).toEqual value: 'test', scopes: ['source.ruby', 'string.regexp.interpolated.ruby']
    expect(tokens[3]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']

    {tokens} = grammar.tokenizeLine('a_method(/test/)')

    expect(tokens[0]).toEqual value: 'a_method', scopes: ['source.ruby']
    expect(tokens[1]).toEqual value: '(', scopes: ['source.ruby', 'punctuation.section.function.ruby']
    expect(tokens[2]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[3]).toEqual value: 'test', scopes: ['source.ruby', 'string.regexp.interpolated.ruby']
    expect(tokens[4]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[5]).toEqual value: ')', scopes: ['source.ruby', 'punctuation.section.function.ruby']

    {tokens} = grammar.tokenizeLine('/test/.match("test")')

    expect(tokens[0]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[1]).toEqual value: 'test', scopes: ['source.ruby', 'string.regexp.interpolated.ruby']
    expect(tokens[2]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[3]).toEqual value: '.', scopes: ['source.ruby', 'punctuation.separator.method.ruby']

    {tokens} = grammar.tokenizeLine('foo(4 / 2).split(/c/)')

    expect(tokens[0]).toEqual value: 'foo', scopes: ['source.ruby']
    expect(tokens[1]).toEqual value: '(', scopes: ['source.ruby', 'punctuation.section.function.ruby']
    expect(tokens[2]).toEqual value: '4', scopes: ['source.ruby', 'constant.numeric.ruby']
    expect(tokens[3]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[4]).toEqual value: '/', scopes: ['source.ruby', 'keyword.operator.arithmetic.ruby']
    expect(tokens[5]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[6]).toEqual value: '2', scopes: ['source.ruby', 'constant.numeric.ruby']
    expect(tokens[7]).toEqual value: ')', scopes: ['source.ruby', 'punctuation.section.function.ruby']
    expect(tokens[8]).toEqual value: '.', scopes: ['source.ruby', 'punctuation.separator.method.ruby']
    expect(tokens[9]).toEqual value: 'split', scopes: ['source.ruby']
    expect(tokens[10]).toEqual value: '(', scopes: ['source.ruby', 'punctuation.section.function.ruby']
    expect(tokens[11]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[12]).toEqual value: 'c', scopes: ['source.ruby', 'string.regexp.interpolated.ruby']
    expect(tokens[13]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[14]).toEqual value: ')', scopes: ['source.ruby', 'punctuation.section.function.ruby']

    {tokens} = grammar.tokenizeLine('[/test/,3]')

    expect(tokens[0]).toEqual value: '[', scopes: ['source.ruby', 'punctuation.section.array.begin.ruby']
    expect(tokens[1]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[2]).toEqual value: 'test', scopes: ['source.ruby', 'string.regexp.interpolated.ruby']
    expect(tokens[3]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[4]).toEqual value: ',', scopes: ['source.ruby', 'punctuation.separator.object.ruby']

    {tokens} = grammar.tokenizeLine('[/test/]')

    expect(tokens[0]).toEqual value: '[', scopes: ['source.ruby', 'punctuation.section.array.begin.ruby']
    expect(tokens[1]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[2]).toEqual value: 'test', scopes: ['source.ruby', 'string.regexp.interpolated.ruby']
    expect(tokens[3]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']

    {tokens} = grammar.tokenizeLine('/test/ && 4')

    expect(tokens[0]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[1]).toEqual value: 'test', scopes: ['source.ruby', 'string.regexp.interpolated.ruby']
    expect(tokens[2]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[3]).toEqual value: ' ', scopes: ['source.ruby']

    {tokens} = grammar.tokenizeLine('/test/ || 4')

    expect(tokens[0]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[1]).toEqual value: 'test', scopes: ['source.ruby', 'string.regexp.interpolated.ruby']
    expect(tokens[2]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[3]).toEqual value: ' ', scopes: ['source.ruby']

    {tokens} = grammar.tokenizeLine('/test/ ? 4 : 3')

    expect(tokens[0]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[1]).toEqual value: 'test', scopes: ['source.ruby', 'string.regexp.interpolated.ruby']
    expect(tokens[2]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[3]).toEqual value: ' ', scopes: ['source.ruby']

    {tokens} = grammar.tokenizeLine('/test/ : foo')

    expect(tokens[0]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[1]).toEqual value: 'test', scopes: ['source.ruby', 'string.regexp.interpolated.ruby']
    expect(tokens[2]).toEqual value: '/', scopes: ['source.ruby', 'string.regexp.interpolated.ruby', 'punctuation.section.regexp.ruby']
    expect(tokens[3]).toEqual value: ' ', scopes: ['source.ruby']

  it "tokenizes the / arithmetic operator", ->
    {tokens} = grammar.tokenizeLine('call/me/maybe')
    expect(tokens[0]).toEqual value: 'call', scopes: ['source.ruby']
    expect(tokens[1]).toEqual value: '/', scopes: ['source.ruby', 'keyword.operator.arithmetic.ruby']
    expect(tokens[2]).toEqual value: 'me', scopes: ['source.ruby']
    expect(tokens[3]).toEqual value: '/', scopes: ['source.ruby', 'keyword.operator.arithmetic.ruby']
    expect(tokens[4]).toEqual value: 'maybe', scopes: ['source.ruby']


    {tokens} = grammar.tokenizeLine('(1+2)/3/4')
    expect(tokens[0]).toEqual value: '(', scopes: ['source.ruby', 'punctuation.section.function.ruby']
    expect(tokens[1]).toEqual value: '1', scopes: ['source.ruby', 'constant.numeric.ruby']
    expect(tokens[2]).toEqual value: '+', scopes: ['source.ruby', 'keyword.operator.arithmetic.ruby']
    expect(tokens[3]).toEqual value: '2', scopes: ['source.ruby', 'constant.numeric.ruby']
    expect(tokens[4]).toEqual value: ')', scopes: ['source.ruby', 'punctuation.section.function.ruby']
    expect(tokens[5]).toEqual value: '/', scopes: ['source.ruby', 'keyword.operator.arithmetic.ruby']
    expect(tokens[6]).toEqual value: '3', scopes: ['source.ruby', 'constant.numeric.ruby']
    expect(tokens[7]).toEqual value: '/', scopes: ['source.ruby', 'keyword.operator.arithmetic.ruby']
    expect(tokens[8]).toEqual value: '4', scopes: ['source.ruby', 'constant.numeric.ruby']

    {tokens} = grammar.tokenizeLine('1 / 2 / 3')
    expect(tokens[0]).toEqual value: '1', scopes: ['source.ruby', 'constant.numeric.ruby']
    expect(tokens[1]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[2]).toEqual value: '/', scopes: ['source.ruby', 'keyword.operator.arithmetic.ruby']
    expect(tokens[3]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[4]).toEqual value: '2', scopes: ['source.ruby', 'constant.numeric.ruby']
    expect(tokens[5]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[6]).toEqual value: '/', scopes: ['source.ruby', 'keyword.operator.arithmetic.ruby']
    expect(tokens[7]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[8]).toEqual value: '3', scopes: ['source.ruby', 'constant.numeric.ruby']

    {tokens} = grammar.tokenizeLine('1/ 2 / 3')
    expect(tokens[0]).toEqual value: '1', scopes: ['source.ruby', 'constant.numeric.ruby']
    expect(tokens[1]).toEqual value: '/', scopes: ['source.ruby', 'keyword.operator.arithmetic.ruby']
    expect(tokens[2]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[3]).toEqual value: '2', scopes: ['source.ruby', 'constant.numeric.ruby']
    expect(tokens[4]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[5]).toEqual value: '/', scopes: ['source.ruby', 'keyword.operator.arithmetic.ruby']
    expect(tokens[6]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[7]).toEqual value: '3', scopes: ['source.ruby', 'constant.numeric.ruby']

    {tokens} = grammar.tokenizeLine('1 / 2/ 3')
    expect(tokens[0]).toEqual value: '1', scopes: ['source.ruby', 'constant.numeric.ruby']
    expect(tokens[1]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[2]).toEqual value: '/', scopes: ['source.ruby', 'keyword.operator.arithmetic.ruby']
    expect(tokens[3]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[4]).toEqual value: '2', scopes: ['source.ruby', 'constant.numeric.ruby']
    expect(tokens[5]).toEqual value: '/', scopes: ['source.ruby', 'keyword.operator.arithmetic.ruby']
    expect(tokens[6]).toEqual value: ' ', scopes: ['source.ruby']
    expect(tokens[7]).toEqual value: '3', scopes: ['source.ruby', 'constant.numeric.ruby']

  it "tokenizes yard documentation comments", ->
    {tokens} = grammar.tokenizeLine('# @private')
    expect(tokens[0]).toEqual value: '#', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'punctuation.definition.comment.ruby']
    expect(tokens[1]).toEqual value: ' ', scopes: ['source.ruby', 'comment.line.number-sign.ruby']
    expect(tokens[2]).toEqual value: '@', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.keyword.punctuation.yard.ruby']
    expect(tokens[3]).toEqual value: 'private', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.keyword.yard.ruby']

    {tokens} = grammar.tokenizeLine('# @deprecated Because I said so')
    expect(tokens[0]).toEqual value: '#', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'punctuation.definition.comment.ruby']
    expect(tokens[1]).toEqual value: ' ', scopes: ['source.ruby', 'comment.line.number-sign.ruby']
    expect(tokens[2]).toEqual value: '@', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.keyword.punctuation.yard.ruby']
    expect(tokens[3]).toEqual value: 'deprecated', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.keyword.yard.ruby']
    expect(tokens[4]).toEqual value: ' Because I said so', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.string.yard.ruby']

    {tokens} = grammar.tokenizeLine('# @raise [Bar] Baz')
    expect(tokens[0]).toEqual value: '#', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'punctuation.definition.comment.ruby']
    expect(tokens[1]).toEqual value: ' ', scopes: ['source.ruby', 'comment.line.number-sign.ruby']
    expect(tokens[2]).toEqual value: '@', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.keyword.punctuation.yard.ruby']
    expect(tokens[3]).toEqual value: 'raise', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.keyword.yard.ruby']
    expect(tokens[4]).toEqual value: ' ', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.yard.ruby']
    expect(tokens[5]).toEqual value: '[', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.yard.ruby', 'comment.line.type.yard.ruby', 'comment.line.punctuation.yard.ruby']
    expect(tokens[6]).toEqual value: 'Bar', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.yard.ruby', 'comment.line.type.yard.ruby']
    expect(tokens[7]).toEqual value: ']', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.yard.ruby', 'comment.line.type.yard.ruby', 'comment.line.punctuation.yard.ruby']
    expect(tokens[8]).toEqual value: ' Baz', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.string.yard.ruby']

    {tokens} = grammar.tokenizeLine('# @param foo [Bar] Baz')
    expect(tokens[0]).toEqual value: '#', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'punctuation.definition.comment.ruby']
    expect(tokens[1]).toEqual value: ' ', scopes: ['source.ruby', 'comment.line.number-sign.ruby']
    expect(tokens[2]).toEqual value: '@', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.keyword.punctuation.yard.ruby']
    expect(tokens[3]).toEqual value: 'param', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.keyword.yard.ruby']
    expect(tokens[4]).toEqual value: ' ', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.yard.ruby']
    expect(tokens[5]).toEqual value: 'foo', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.yard.ruby', 'comment.line.parameter.yard.ruby']
    expect(tokens[6]).toEqual value: ' ', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.yard.ruby']
    expect(tokens[7]).toEqual value: '[', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.yard.ruby', 'comment.line.type.yard.ruby', 'comment.line.punctuation.yard.ruby']
    expect(tokens[8]).toEqual value: 'Bar', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.yard.ruby', 'comment.line.type.yard.ruby']
    expect(tokens[9]).toEqual value: ']', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.yard.ruby', 'comment.line.type.yard.ruby', 'comment.line.punctuation.yard.ruby']
    expect(tokens[10]).toEqual value: ' Baz', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.string.yard.ruby']

    {tokens} = grammar.tokenizeLine('# @param [Bar] Baz')
    expect(tokens[0]).toEqual value: '#', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'punctuation.definition.comment.ruby']
    expect(tokens[1]).toEqual value: ' ', scopes: ['source.ruby', 'comment.line.number-sign.ruby']
    expect(tokens[2]).toEqual value: '@', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.keyword.punctuation.yard.ruby']
    expect(tokens[3]).toEqual value: 'param', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.keyword.yard.ruby']
    expect(tokens[4]).toEqual value: ' ', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.yard.ruby']
    expect(tokens[5]).toEqual value: '[', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.yard.ruby', 'comment.line.type.yard.ruby', 'comment.line.punctuation.yard.ruby']
    expect(tokens[6]).toEqual value: 'Bar', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.yard.ruby', 'comment.line.type.yard.ruby']
    expect(tokens[7]).toEqual value: ']', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.yard.ruby', 'comment.line.type.yard.ruby', 'comment.line.punctuation.yard.ruby']
    expect(tokens[8]).toEqual value: ' Baz', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.string.yard.ruby']


    {tokens} = grammar.tokenizeLine('# @return [Array#[](0), Array] comment')
    expect(tokens[0]).toEqual value: '#', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'punctuation.definition.comment.ruby']
    expect(tokens[1]).toEqual value: ' ', scopes: ['source.ruby', 'comment.line.number-sign.ruby']
    expect(tokens[2]).toEqual value: '@', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.keyword.punctuation.yard.ruby']
    expect(tokens[3]).toEqual value: 'return', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.keyword.yard.ruby']
    expect(tokens[4]).toEqual value: ' ', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.yard.ruby']
    expect(tokens[5]).toEqual value: '[', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.yard.ruby', 'comment.line.type.yard.ruby', 'comment.line.punctuation.yard.ruby']
    expect(tokens[6]).toEqual value: 'Array#[](0), Array', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.yard.ruby', 'comment.line.type.yard.ruby']
    expect(tokens[7]).toEqual value: ']', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.yard.ruby', 'comment.line.type.yard.ruby', 'comment.line.punctuation.yard.ruby']
    expect(tokens[8]).toEqual value: ' comment', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.string.yard.ruby']

    {tokens} = grammar.tokenizeLine('# @param [Array#[](0), Array] comment')
    expect(tokens[0]).toEqual value: '#', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'punctuation.definition.comment.ruby']
    expect(tokens[1]).toEqual value: ' ', scopes: ['source.ruby', 'comment.line.number-sign.ruby']
    expect(tokens[2]).toEqual value: '@', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.keyword.punctuation.yard.ruby']
    expect(tokens[3]).toEqual value: 'param', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.keyword.yard.ruby']
    expect(tokens[4]).toEqual value: ' ', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.yard.ruby']
    expect(tokens[5]).toEqual value: '[', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.yard.ruby', 'comment.line.type.yard.ruby', 'comment.line.punctuation.yard.ruby']
    expect(tokens[6]).toEqual value: 'Array#[](0), Array', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.yard.ruby', 'comment.line.type.yard.ruby']
    expect(tokens[7]).toEqual value: ']', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.yard.ruby', 'comment.line.type.yard.ruby', 'comment.line.punctuation.yard.ruby']
    expect(tokens[8]).toEqual value: ' comment', scopes: ['source.ruby', 'comment.line.number-sign.ruby', 'comment.line.string.yard.ruby']
