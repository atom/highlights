_ = require 'underscore-plus'
fs = require 'fs-plus'
{GrammarRegistry} = require 'first-mate'

module.exports =
class Highlights
  constructor: ->
    @registry = new GrammarRegistry()

  # Public: Syntax highlight the given file synchronously
  #
  # filePath  - The String path to the file.
  # scopeName - An optional String scope name of a grammar. The best match
  #             grammar will be used if unspecified.
  #
  # Returns a String of HTML. The HTML will contains one <div> per line and each
  # line will contain one or more <span> elements for the tokens in the line.
  highlightFileSync: (filePath, scopeName) ->
    fileContents = fs.readFileSync(filePath, 'utf8')
    grammar = @registry.grammarForScopeName(scopeName)
    grammar ?= @registry.selectGrammar(filePath, fileContents)
    lineTokens = grammar.tokenizeLines(fileContents)

    # Remove trailing newline
    if lineTokens.length > 0
      lastLineTokens = lineTokens[lineTokens.length - 1]
      if lastLineTokens.length is 1 and lastLineTokens[0].value is ''
        lineTokens.pop()

    html = ''
    for tokens in lineTokens
      scopeStack = []
      html += '<div class="line">'
      for {scopes, value} in tokens
        value = ' ' unless value
        html = @updateScopeStack(scopeStack, scopes, html)
        html += "<span>#{@escapeString(value)}</span>"

      html += '</div>'
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
      popScope(scopeStack) while excessScopes--

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
    html += "<span class=\"#{scope.replace(/\./g, ' ')}\">"

  popScope: (scopeStack, html) ->
    scopeStack.pop()
    html += '</span>'
