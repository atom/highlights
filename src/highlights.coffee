path = require 'path'
_ = require 'underscore-plus'
fs = require 'fs-plus'
CSON = require 'season'
{GrammarRegistry} = require 'first-mate'

module.exports =
class Highlights
  # Public: Create a new highlighter.
  #
  # options - An Object with the following keys:
  #   :includePath - An optional String path to a file or folder of grammars to
  #                  register.
  #   :registry    - An optional GrammarRegistry instance.
  constructor: ({@includePath, @registry}={}) ->
    @registry ?= new GrammarRegistry(maxTokensPerLine: Infinity)

  loadGrammarsSync: ->
    return if @registry.grammars.length > 1

    if typeof @includePath is 'string'
      if fs.isFileSync(@includePath)
        @registry.loadGrammarSync(@includePath)
      else if fs.isDirectorySync(@includePath)
        for filePath in fs.listSync(@includePath, ['cson', 'json'])
          @registry.loadGrammarSync(filePath)

    grammarsPath = path.join(__dirname, '..', 'gen', 'grammars.json')
    for grammarPath, grammar of JSON.parse(fs.readFileSync(grammarsPath))
      continue if @registry.grammarForScopeName(grammar.scopeName)?
      grammar = @registry.createGrammar(grammarPath, grammar)
      @registry.addGrammar(grammar)

  # Public: allows grammars to be loaded from
  #   an npm module.
  #  :modulePath - the path to the module to require.
  requireGrammarsSync: ({modulePath}={}) ->
    @loadGrammarsSync()

    packageDir = path.dirname(modulePath)
    grammarsDir = path.resolve(packageDir, 'grammars')

    return unless fs.isDirectorySync(grammarsDir)

    for file in fs.readdirSync(grammarsDir)
      if grammarPath = CSON.resolve(path.join(grammarsDir, file))
        @registry.loadGrammarSync(grammarPath)

  # Public: Syntax highlight the given file synchronously.
  #
  # options - An Object with the following keys:
  #   :fileContents - The optional String contents of the file. The file will
  #                   be read from disk if this is unspecified
  #   :filePath     - The String path to the file.
  #   :scopeName    - An optional String scope name of a grammar. The best match
  #                   grammar will be used if this is unspecified.
  #
  # Returns a String of HTML. The HTML will contains one <pre> with one <div>
  # per line and each line will contain one or more <span> elements for the
  # tokens in the line.
  highlightSync: ({filePath, fileContents, scopeName}={}) ->
    @loadGrammarsSync()

    fileContents ?= fs.readFileSync(filePath, 'utf8') if filePath
    grammar = @registry.grammarForScopeName(scopeName)
    grammar ?= @registry.selectGrammar(filePath, fileContents)
    lineTokens = grammar.tokenizeLines(fileContents)

    # Remove trailing newline
    if lineTokens.length > 0
      lastLineTokens = lineTokens[lineTokens.length - 1]
      if lastLineTokens.length is 1 and lastLineTokens[0].value is ''
        lineTokens.pop()

    html = '<pre class="editor editor-colors">'
    for tokens in lineTokens
      scopeStack = []
      html += '<div class="line">'
      for {scopes, value} in tokens
        value = ' ' unless value
        html = @updateScopeStack(scopeStack, scopes, html)
        html += "<span>#{@escapeString(value)}</span>"
      html = @popScope(scopeStack, html) while scopeStack.length > 0
      html += '</div>'
    html += '</pre>'
    html

  escapeString: (string) ->
    string.replace /[&"'<> ]/g, (match) ->
      switch match
        when '&' then '&amp;'
        when '"' then '&quot;'
        when "'" then '&#39;'
        when '<' then '&lt;'
        when '>' then '&gt;'
        when ' ' then '&nbsp;'
        else match

  updateScopeStack: (scopeStack, desiredScopes, html) ->
    excessScopes = scopeStack.length - desiredScopes.length
    if excessScopes > 0
      html = @popScope(scopeStack, html) while excessScopes--

    # pop until common prefix
    for i in [scopeStack.length..0]
      break if _.isEqual(scopeStack[0...i], desiredScopes[0...i])
      html = @popScope(scopeStack, html)

    # push on top of common prefix until scopeStack is desiredScopes
    for j in [i...desiredScopes.length]
      html = @pushScope(scopeStack, desiredScopes[j], html)

    html

  pushScope: (scopeStack, scope, html) ->
    scopeStack.push(scope)
    html += "<span class=\"#{scope.replace(/\.+/g, ' ')}\">"

  popScope: (scopeStack, html) ->
    scopeStack.pop()
    html += '</span>'
