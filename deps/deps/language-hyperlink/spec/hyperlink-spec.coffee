describe 'Hyperlink grammar', ->
  grammar = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage('language-hyperlink')

    runs ->
      grammar = atom.grammars.grammarForScopeName('text.hyperlink')

  it 'parses the grammar', ->
    expect(grammar).toBeTruthy()
    expect(grammar.scopeName).toBe 'text.hyperlink'

  it 'parses http: and https: links', ->
    plainGrammar = atom.grammars.selectGrammar()

    {tokens} = plainGrammar.tokenizeLine 'http://github.com'
    expect(tokens[0]).toEqual value: 'http://github.com', scopes: ['text.plain.null-grammar', 'markup.underline.link.http.hyperlink']

    {tokens} = plainGrammar.tokenizeLine 'https://github.com'
    expect(tokens[0]).toEqual value: 'https://github.com', scopes: ['text.plain.null-grammar', 'markup.underline.link.https.hyperlink']
