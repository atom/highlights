_ = require 'underscore-plus'

module.exports =
class TokensToHTML
  # Returns HTML string ready for syntax highlighting with CSS, given an Array
  # of tokenized lines.  Each tokenized line is itself an Array of tokens.
  # Each token is an Object with two keys:
  #   :value  - the substring of the source text corresponding to the token
  #   :scopes - an Array of CSS class names that apply to the token, in the
  #             order from the least to the most specific, e.g.:
  #             ['source.python', 'keyword.other.python']
  # Essentially the output HTML for each token is:
  #    <span class="${scopes}">${escape(value)}</span>
  # ...but we try to minimize the number of CSS classes on each span, by nesting
  # consecutive spans with a common scope in a parent <span class="common scopes">.
  @highlightFromTokens: (lineTokens) ->
    # Remove trailing newline
    if lineTokens.length > 0
      lastLineTokens = lineTokens[lineTokens.length - 1]

      if lastLineTokens.length is 1 and lastLineTokens[0].value is ''
        lineTokens.pop()

    html = '<pre class="editor editor-colors">'
    for tokens in lineTokens
      scopeStack = []
      html += '<div class="line">'
      for {value, scopes} in tokens
        value = ' ' unless value
        html = @updateScopeStack(scopeStack, scopes, html)
        html += "<span>#{@escapeString(value)}</span>"
      html = @popScope(scopeStack, html) while scopeStack.length > 0
      html += '</div>'
    html += '</pre>'
    html

  @escapeString: (string) ->
    string.replace /[&"'<> ]/g, (match) ->
      switch match
        when '&' then '&amp;'
        when '"' then '&quot;'
        when "'" then '&#39;'
        when '<' then '&lt;'
        when '>' then '&gt;'
        when ' ' then '&nbsp;'
        else match

  @updateScopeStack: (scopeStack, desiredScopes, html) ->
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

  @pushScope: (scopeStack, scope, html) ->
    scopeStack.push(scope)
    html += "<span class=\"#{scope.replace(/\.+/g, ' ')}\">"

  @popScope: (scopeStack, html) ->
    scopeStack.pop()
    html += '</span>'
