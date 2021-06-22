describe "YAML grammar", ->
  grammar = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage("language-yaml")

    runs ->
      grammar = atom.grammars.grammarForScopeName('source.yaml')

  it "parses the grammar", ->
    expect(grammar).toBeTruthy()
    expect(grammar.scopeName).toBe "source.yaml"

  it "selects the grammar for cloud config files", ->
    waitsForPromise ->
      atom.workspace.open('cloud.config')

    runs ->
      expect(atom.workspace.getActiveTextEditor().getGrammar()).toBe grammar

  describe "strings", ->
    describe "double quoted", ->
      it "parses escaped quotes", ->
        {tokens} = grammar.tokenizeLine("\"I am \\\"escaped\\\"\"")
        expect(tokens[0]).toEqual value: "\"", scopes: ["source.yaml", "string.quoted.double.yaml", "punctuation.definition.string.begin.yaml"]
        expect(tokens[1]).toEqual value: "I am ", scopes: ["source.yaml", "string.quoted.double.yaml"]
        expect(tokens[2]).toEqual value: "\\\"", scopes: ["source.yaml", "string.quoted.double.yaml", "constant.character.escape.yaml"]
        expect(tokens[3]).toEqual value: "escaped", scopes: ["source.yaml", "string.quoted.double.yaml"]
        expect(tokens[4]).toEqual value: "\\\"", scopes: ["source.yaml", "string.quoted.double.yaml", "constant.character.escape.yaml"]
        expect(tokens[5]).toEqual value: "\"", scopes: ["source.yaml", "string.quoted.double.yaml", "punctuation.definition.string.end.yaml"]


        {tokens} = grammar.tokenizeLine("key: \"I am \\\"escaped\\\"\"")
        expect(tokens[0]).toEqual value: "key", scopes: ["source.yaml", "string.unquoted.yaml", "entity.name.tag.yaml"]
        expect(tokens[1]).toEqual value: ":", scopes: ["source.yaml", "string.unquoted.yaml", "entity.name.tag.yaml", "punctuation.separator.key-value.yaml"]
        expect(tokens[2]).toEqual value: " ", scopes: ["source.yaml", "string.unquoted.yaml"]
        expect(tokens[3]).toEqual value: "\"", scopes: ["source.yaml", "string.unquoted.yaml", "string.quoted.double.yaml", "punctuation.definition.string.begin.yaml"]
        expect(tokens[4]).toEqual value: "I am ", scopes: ["source.yaml", "string.unquoted.yaml", "string.quoted.double.yaml"]
        expect(tokens[5]).toEqual value: "\\\"", scopes: ["source.yaml", "string.unquoted.yaml", "string.quoted.double.yaml", "constant.character.escape.yaml"]
        expect(tokens[6]).toEqual value: "escaped", scopes: ["source.yaml", "string.unquoted.yaml", "string.quoted.double.yaml"]
        expect(tokens[7]).toEqual value: "\\\"", scopes: ["source.yaml", "string.unquoted.yaml", "string.quoted.double.yaml", "constant.character.escape.yaml"]
        expect(tokens[8]).toEqual value: "\"", scopes: ["source.yaml", "string.unquoted.yaml", "string.quoted.double.yaml", "punctuation.definition.string.end.yaml"]

    describe "single quoted", ->
      it "parses escaped quotes", ->
        {tokens} = grammar.tokenizeLine("'I am \\'escaped\\''")
        expect(tokens[0]).toEqual value: "'", scopes: ["source.yaml", "string.quoted.single.yaml", "punctuation.definition.string.begin.yaml"]
        expect(tokens[1]).toEqual value: "I am ", scopes: ["source.yaml", "string.quoted.single.yaml"]
        expect(tokens[2]).toEqual value: "\\'", scopes: ["source.yaml", "string.quoted.single.yaml", "constant.character.escape.yaml"]
        expect(tokens[3]).toEqual value: "escaped", scopes: ["source.yaml", "string.quoted.single.yaml"]
        expect(tokens[4]).toEqual value: "\\'", scopes: ["source.yaml", "string.quoted.single.yaml", "constant.character.escape.yaml"]
        expect(tokens[5]).toEqual value: "'", scopes: ["source.yaml", "string.quoted.single.yaml", "punctuation.definition.string.end.yaml"]

        {tokens} = grammar.tokenizeLine("key: 'I am \\'escaped\\''")
        expect(tokens[0]).toEqual value: "key", scopes: ["source.yaml", "string.unquoted.yaml", "entity.name.tag.yaml"]
        expect(tokens[1]).toEqual value: ":", scopes: ["source.yaml", "string.unquoted.yaml", "entity.name.tag.yaml", "punctuation.separator.key-value.yaml"]
        expect(tokens[2]).toEqual value: " ", scopes: ["source.yaml", "string.unquoted.yaml"]
        expect(tokens[3]).toEqual value: "'", scopes: ["source.yaml", "string.unquoted.yaml", "string.quoted.single.yaml", "punctuation.definition.string.begin.yaml"]
        expect(tokens[4]).toEqual value: "I am ", scopes: ["source.yaml", "string.unquoted.yaml", "string.quoted.single.yaml"]
        expect(tokens[5]).toEqual value: "\\'", scopes: ["source.yaml", "string.unquoted.yaml", "string.quoted.single.yaml", "constant.character.escape.yaml"]
        expect(tokens[6]).toEqual value: "escaped", scopes: ["source.yaml", "string.unquoted.yaml", "string.quoted.single.yaml"]
        expect(tokens[7]).toEqual value: "\\'", scopes: ["source.yaml", "string.unquoted.yaml", "string.quoted.single.yaml", "constant.character.escape.yaml"]
        expect(tokens[8]).toEqual value: "'", scopes: ["source.yaml", "string.unquoted.yaml", "string.quoted.single.yaml", "punctuation.definition.string.end.yaml"]

    describe "text blocks", ->
      it "parses simple content", ->
        lines = grammar.tokenizeLines """
        key: |
          content here
          second line
        """
        expect(lines[0][0]).toEqual value: "key", scopes: ["source.yaml", "string.unquoted.block.yaml", "entity.name.tag.yaml"]
        expect(lines[0][1]).toEqual value: ":", scopes: ["source.yaml", "string.unquoted.block.yaml", "entity.name.tag.yaml", "punctuation.separator.key-value.yaml"]
        expect(lines[1][0]).toEqual value: "  content here", scopes: ["source.yaml", "string.unquoted.block.yaml"]
        expect(lines[2][0]).toEqual value: "  second line", scopes: ["source.yaml", "string.unquoted.block.yaml"]

      it "parses content with empty lines", ->
        lines = grammar.tokenizeLines """
        key: |
          content here

          second line
        """
        expect(lines[0][0]).toEqual value: "key", scopes: ["source.yaml", "string.unquoted.block.yaml", "entity.name.tag.yaml"]
        expect(lines[0][1]).toEqual value: ":", scopes: ["source.yaml", "string.unquoted.block.yaml", "entity.name.tag.yaml", "punctuation.separator.key-value.yaml"]
        expect(lines[1][0]).toEqual value: "  content here", scopes: ["source.yaml", "string.unquoted.block.yaml"]
        expect(lines[2][0]).toEqual value: "", scopes: ["source.yaml", "string.unquoted.block.yaml"]
        expect(lines[3][0]).toEqual value: "  second line", scopes: ["source.yaml", "string.unquoted.block.yaml"]

      it "parses keys with decimals", ->
        lines = grammar.tokenizeLines """
        2.0: |
          content here
          second line
        """
        expect(lines[0][0]).toEqual value: "2.0", scopes: ["source.yaml", "string.unquoted.block.yaml", "entity.name.tag.yaml"]
        expect(lines[0][1]).toEqual value: ":", scopes: ["source.yaml", "string.unquoted.block.yaml", "entity.name.tag.yaml", "punctuation.separator.key-value.yaml"]
        expect(lines[1][0]).toEqual value: "  content here", scopes: ["source.yaml", "string.unquoted.block.yaml"]
        expect(lines[2][0]).toEqual value: "  second line", scopes: ["source.yaml", "string.unquoted.block.yaml"]

      it "properly parses comments in blocks", ->
        lines = grammar.tokenizeLines """
        key: |
          # this is a legit comment
          no highlights
        key: |
          ### this is just a markdown header
          second line
        """
        expect(lines[0][0]).toEqual value: "key", scopes: ["source.yaml", "string.unquoted.block.yaml", "entity.name.tag.yaml"]
        expect(lines[0][1]).toEqual value: ":", scopes: ["source.yaml", "string.unquoted.block.yaml", "entity.name.tag.yaml", "punctuation.separator.key-value.yaml"]
        expect(lines[1][0]).toEqual value: "  ", scopes: ["source.yaml", "punctuation.whitespace.comment.leading.yaml"]
        expect(lines[1][1]).toEqual value: "#", scopes: ["source.yaml", "comment.line.number-sign.yaml", "punctuation.definition.comment.yaml"]
        expect(lines[1][2]).toEqual value: " this is a legit comment", scopes: ["source.yaml", "comment.line.number-sign.yaml"]
        expect(lines[2][0]).toEqual value: "  no highlights", scopes: ["source.yaml"]

        expect(lines[3][0]).toEqual value: "key", scopes: ["source.yaml", "string.unquoted.block.yaml", "entity.name.tag.yaml"]
        expect(lines[3][1]).toEqual value: ":", scopes: ["source.yaml", "string.unquoted.block.yaml", "entity.name.tag.yaml", "punctuation.separator.key-value.yaml"]
        expect(lines[4][0]).toEqual value: "  ### this is just a markdown header", scopes: ["source.yaml", "string.unquoted.block.yaml"]
        expect(lines[5][0]).toEqual value: "  second line", scopes: ["source.yaml", "string.unquoted.block.yaml"]

      describe "parses content with unindented empty lines", ->
        it "ending the content", ->
          lines = grammar.tokenizeLines """
          key: |
            content here

            second line
          """
          expect(lines[0][0]).toEqual value: "key", scopes: ["source.yaml", "string.unquoted.block.yaml", "entity.name.tag.yaml"]
          expect(lines[0][1]).toEqual value: ":", scopes: ["source.yaml", "string.unquoted.block.yaml", "entity.name.tag.yaml", "punctuation.separator.key-value.yaml"]
          expect(lines[0][2]).toEqual value: " |", scopes: ["source.yaml", "string.unquoted.block.yaml"]
          expect(lines[1][0]).toEqual value: "  content here", scopes: ["source.yaml", "string.unquoted.block.yaml"]
          expect(lines[2][0]).toEqual value: "", scopes: ["source.yaml", "string.unquoted.block.yaml"]
          expect(lines[3][0]).toEqual value: "  second line", scopes: ["source.yaml", "string.unquoted.block.yaml"]

        it "ending with new element", ->
          lines = grammar.tokenizeLines """
          key: |
            content here

            second line
          other: hi
          """
          expect(lines[0][0]).toEqual value: "key", scopes: ["source.yaml", "string.unquoted.block.yaml", "entity.name.tag.yaml"]
          expect(lines[0][1]).toEqual value: ":", scopes: ["source.yaml", "string.unquoted.block.yaml", "entity.name.tag.yaml", "punctuation.separator.key-value.yaml"]
          expect(lines[0][2]).toEqual value: " |", scopes: ["source.yaml", "string.unquoted.block.yaml"]
          expect(lines[1][0]).toEqual value: "  content here", scopes: ["source.yaml", "string.unquoted.block.yaml"]
          expect(lines[2][0]).toEqual value: "", scopes: ["source.yaml", "string.unquoted.block.yaml"]
          expect(lines[3][0]).toEqual value: "  second line", scopes: ["source.yaml", "string.unquoted.block.yaml"]
          expect(lines[4][0]).toEqual value: "other", scopes: ["source.yaml", "string.unquoted.yaml", "entity.name.tag.yaml"]
          expect(lines[4][1]).toEqual value: ":", scopes: ["source.yaml", "string.unquoted.yaml", "entity.name.tag.yaml", "punctuation.separator.key-value.yaml"]
          expect(lines[4][2]).toEqual value: " ", scopes: ["source.yaml", "string.unquoted.yaml"]
          expect(lines[4][3]).toEqual value: "hi", scopes: ["source.yaml", "string.unquoted.yaml", "string.unquoted.yaml"]

        it "ending with new element, part of list", ->
          lines = grammar.tokenizeLines """
           - key: |
               content here

               second line
           - other: hi
          """
          expect(lines[0][0]).toEqual value: "- ", scopes: ["source.yaml", "string.unquoted.block.yaml", "punctuation.definition.entry.yaml"]
          expect(lines[0][1]).toEqual value: "key", scopes: ["source.yaml", "string.unquoted.block.yaml", "entity.name.tag.yaml"]
          expect(lines[0][2]).toEqual value: ":", scopes: ["source.yaml", "string.unquoted.block.yaml", "entity.name.tag.yaml", "punctuation.separator.key-value.yaml"]
          expect(lines[0][3]).toEqual value: " |", scopes: ["source.yaml", "string.unquoted.block.yaml"]
          expect(lines[1][0]).toEqual value: "    content here", scopes: ["source.yaml", "string.unquoted.block.yaml"]
          expect(lines[2][0]).toEqual value: "", scopes: ["source.yaml", "string.unquoted.block.yaml"]
          expect(lines[3][0]).toEqual value: "    second line", scopes: ["source.yaml", "string.unquoted.block.yaml"]
          expect(lines[4][0]).toEqual value: "- ", scopes: ["source.yaml", "string.unquoted.yaml", "punctuation.definition.entry.yaml"]
          expect(lines[4][1]).toEqual value: "other", scopes: ["source.yaml", "string.unquoted.yaml", "entity.name.tag.yaml"]
          expect(lines[4][2]).toEqual value: ":", scopes: ["source.yaml", "string.unquoted.yaml", "entity.name.tag.yaml", "punctuation.separator.key-value.yaml"]
          expect(lines[4][3]).toEqual value: " ", scopes: ["source.yaml", "string.unquoted.yaml"]
          expect(lines[4][4]).toEqual value: "hi", scopes: ["source.yaml", "string.unquoted.yaml", "string.unquoted.yaml"]

        it "ending with twice unindented new element", ->
          lines = grammar.tokenizeLines """
          root:
            key: |
              content here

              second line
          other: hi
          """
          expect(lines[1][1]).toEqual value: "key", scopes: ["source.yaml", "string.unquoted.block.yaml", "entity.name.tag.yaml"]
          expect(lines[1][2]).toEqual value: ":", scopes: ["source.yaml", "string.unquoted.block.yaml", "entity.name.tag.yaml", "punctuation.separator.key-value.yaml"]
          expect(lines[1][3]).toEqual value: " |", scopes: ["source.yaml", "string.unquoted.block.yaml"]
          expect(lines[2][0]).toEqual value: "    content here", scopes: ["source.yaml", "string.unquoted.block.yaml"]
          expect(lines[3][0]).toEqual value: "", scopes: ["source.yaml", "string.unquoted.block.yaml"]
          expect(lines[4][0]).toEqual value: "    second line", scopes: ["source.yaml", "string.unquoted.block.yaml"]
          expect(lines[5][0]).toEqual value: "other", scopes: ["source.yaml", "string.unquoted.yaml", "entity.name.tag.yaml"]
          expect(lines[5][1]).toEqual value: ":", scopes: ["source.yaml", "string.unquoted.yaml", "entity.name.tag.yaml", "punctuation.separator.key-value.yaml"]
          expect(lines[5][2]).toEqual value: " ", scopes: ["source.yaml", "string.unquoted.yaml"]
          expect(lines[5][3]).toEqual value: "hi", scopes: ["source.yaml", "string.unquoted.yaml", "string.unquoted.yaml"]

        it "ending with an indented comment", ->
          lines = grammar.tokenizeLines """
          root:
            key: |
              content here

              second line
            # hi
          """
          expect(lines[1][1]).toEqual value: "key", scopes: ["source.yaml", "string.unquoted.block.yaml", "entity.name.tag.yaml"]
          expect(lines[1][2]).toEqual value: ":", scopes: ["source.yaml", "string.unquoted.block.yaml", "entity.name.tag.yaml", "punctuation.separator.key-value.yaml"]
          expect(lines[1][3]).toEqual value: " |", scopes: ["source.yaml", "string.unquoted.block.yaml"]
          expect(lines[2][0]).toEqual value: "    content here", scopes: ["source.yaml", "string.unquoted.block.yaml"]
          expect(lines[3][0]).toEqual value: "", scopes: ["source.yaml", "string.unquoted.block.yaml"]
          expect(lines[4][0]).toEqual value: "    second line", scopes: ["source.yaml", "string.unquoted.block.yaml"]
          expect(lines[5][0]).toEqual value: "  ", scopes: ["source.yaml", "punctuation.whitespace.comment.leading.yaml"]
          expect(lines[5][1]).toEqual value: "#", scopes: ["source.yaml", "comment.line.number-sign.yaml", "punctuation.definition.comment.yaml"]
          expect(lines[5][2]).toEqual value: " hi", scopes: ["source.yaml", "comment.line.number-sign.yaml"]

  it "parses the leading ! before values", ->
    {tokens} = grammar.tokenizeLine("key: ! 'hi'")
    expect(tokens[0]).toEqual value: "key", scopes: ["source.yaml", "string.unquoted.yaml", "entity.name.tag.yaml"]
    expect(tokens[1]).toEqual value: ":", scopes: ["source.yaml", "string.unquoted.yaml", "entity.name.tag.yaml", "punctuation.separator.key-value.yaml"]
    expect(tokens[2]).toEqual value: " ", scopes: ["source.yaml", "string.unquoted.yaml"]
    expect(tokens[3]).toEqual value: "! ", scopes: ["source.yaml", "string.unquoted.yaml", "string.unquoted.yaml"]
    expect(tokens[4]).toEqual value: "'", scopes: ["source.yaml", "string.unquoted.yaml", "string.quoted.single.yaml", "punctuation.definition.string.begin.yaml"]
    expect(tokens[5]).toEqual value: "hi", scopes: ["source.yaml", "string.unquoted.yaml", "string.quoted.single.yaml"]
    expect(tokens[6]).toEqual value: "'", scopes: ["source.yaml", "string.unquoted.yaml", "string.quoted.single.yaml",  "punctuation.definition.string.end.yaml"]

  it "parses nested keys", ->
    lines = grammar.tokenizeLines """
      first:
        second:
          third: 3
          fourth: "4th"
    """

    expect(lines[0][0]).toEqual value: "first", scopes: ["source.yaml", "string.unquoted.yaml", "entity.name.tag.yaml"]
    expect(lines[0][1]).toEqual value: ":", scopes: ["source.yaml", "string.unquoted.yaml", "entity.name.tag.yaml", "punctuation.separator.key-value.yaml"]

    expect(lines[1][0]).toEqual value: "  ", scopes: ["source.yaml"]
    expect(lines[1][1]).toEqual value: "second", scopes: ["source.yaml", "string.unquoted.yaml", "entity.name.tag.yaml"]
    expect(lines[1][2]).toEqual value: ":", scopes: ["source.yaml", "string.unquoted.yaml", "entity.name.tag.yaml", "punctuation.separator.key-value.yaml"]

    expect(lines[2][0]).toEqual value: "    ", scopes: ["source.yaml"]
    expect(lines[2][1]).toEqual value: "third", scopes: ["source.yaml", "constant.numeric.yaml", "entity.name.tag.yaml"]
    expect(lines[2][2]).toEqual value: ":", scopes: ["source.yaml", "constant.numeric.yaml", "entity.name.tag.yaml", "punctuation.separator.key-value.yaml"]
    expect(lines[2][3]).toEqual value: " 3", scopes: ["source.yaml", "constant.numeric.yaml"]

    expect(lines[3][0]).toEqual value: "    ", scopes: ["source.yaml"]
    expect(lines[3][1]).toEqual value: "fourth", scopes: ["source.yaml", "string.unquoted.yaml", "entity.name.tag.yaml"]
    expect(lines[3][2]).toEqual value: ":", scopes: ["source.yaml", "string.unquoted.yaml", "entity.name.tag.yaml", "punctuation.separator.key-value.yaml"]
    expect(lines[3][3]).toEqual value: " ", scopes: ["source.yaml", "string.unquoted.yaml"]
    expect(lines[3][4]).toEqual value: "\"", scopes: ["source.yaml", "string.unquoted.yaml", "string.quoted.double.yaml", "punctuation.definition.string.begin.yaml"]
    expect(lines[3][5]).toEqual value: "4th", scopes: ["source.yaml", "string.unquoted.yaml", "string.quoted.double.yaml"]
    expect(lines[3][6]).toEqual value: "\"", scopes: ["source.yaml", "string.unquoted.yaml", "string.quoted.double.yaml", "punctuation.definition.string.end.yaml"]

  it "parses keys and values", ->
    lines = grammar.tokenizeLines """
      first: 1st
      second: 2nd
      third: th{ree}
    """

    expect(lines[0][0]).toEqual value: "first", scopes: ["source.yaml", "string.unquoted.yaml", "entity.name.tag.yaml"]
    expect(lines[0][1]).toEqual value: ":", scopes: ["source.yaml", "string.unquoted.yaml", "entity.name.tag.yaml", "punctuation.separator.key-value.yaml"]
    expect(lines[0][2]).toEqual value: " ", scopes: ["source.yaml", "string.unquoted.yaml"]
    expect(lines[0][3]).toEqual value: "1st", scopes: ["source.yaml", "string.unquoted.yaml", "string.unquoted.yaml"]

    expect(lines[1][0]).toEqual value: "second", scopes: ["source.yaml", "string.unquoted.yaml", "entity.name.tag.yaml"]
    expect(lines[1][1]).toEqual value: ":", scopes: ["source.yaml", "string.unquoted.yaml", "entity.name.tag.yaml", "punctuation.separator.key-value.yaml"]
    expect(lines[1][2]).toEqual value: " ", scopes: ["source.yaml", "string.unquoted.yaml"]
    expect(lines[1][3]).toEqual value: "2nd", scopes: ["source.yaml", "string.unquoted.yaml", "string.unquoted.yaml"]

    expect(lines[2][0]).toEqual value: "third", scopes: ["source.yaml", "string.unquoted.yaml", "entity.name.tag.yaml"]
    expect(lines[2][1]).toEqual value: ":", scopes: ["source.yaml", "string.unquoted.yaml", "entity.name.tag.yaml", "punctuation.separator.key-value.yaml"]
    expect(lines[2][2]).toEqual value: " ", scopes: ["source.yaml", "string.unquoted.yaml"]
    expect(lines[2][3]).toEqual value: "th{ree}", scopes: ["source.yaml", "string.unquoted.yaml", "string.unquoted.yaml"]

  it "parses comments at the beginning of lines", ->
    lines = grammar.tokenizeLines """
      # first: 1
        # second
      ##
    """

    expect(lines[0][0]).toEqual value: "#", scopes: ["source.yaml", "comment.line.number-sign.yaml", "punctuation.definition.comment.yaml"]
    expect(lines[0][1]).toEqual value: " first: 1", scopes: ["source.yaml", "comment.line.number-sign.yaml"]

    expect(lines[1][0]).toEqual value: "  ", scopes: ["source.yaml", "punctuation.whitespace.comment.leading.yaml"]
    expect(lines[1][1]).toEqual value: "#", scopes: ["source.yaml", "comment.line.number-sign.yaml", "punctuation.definition.comment.yaml"]
    expect(lines[1][2]).toEqual value: " second", scopes: ["source.yaml", "comment.line.number-sign.yaml"]

    expect(lines[2][0]).toEqual value: "#", scopes: ["source.yaml", "comment.line.number-sign.yaml", "punctuation.definition.comment.yaml"]
    expect(lines[2][1]).toEqual value: "#", scopes: ["source.yaml", "comment.line.number-sign.yaml"]

  it "parses comments at the end of lines", ->
    lines = grammar.tokenizeLines """
      first: 1 # foo
      second: 2nd  #bar
      third: "3"
      fourth: four#
    """

    expect(lines[0][0]).toEqual value: "first", scopes: ["source.yaml", "constant.numeric.yaml", "entity.name.tag.yaml"]
    expect(lines[0][1]).toEqual value: ":", scopes: ["source.yaml", "constant.numeric.yaml", "entity.name.tag.yaml", "punctuation.separator.key-value.yaml"]
    expect(lines[0][2]).toEqual value: " 1 ", scopes: ["source.yaml", "constant.numeric.yaml"]
    expect(lines[0][3]).toEqual value: "#", scopes: ["source.yaml", "comment.line.number-sign.yaml", "punctuation.definition.comment.yaml"]
    expect(lines[0][4]).toEqual value: " foo", scopes: ["source.yaml", "comment.line.number-sign.yaml"]

    expect(lines[1][0]).toEqual value: "second", scopes: ["source.yaml", "string.unquoted.yaml", "entity.name.tag.yaml"]
    expect(lines[1][1]).toEqual value: ":", scopes: ["source.yaml", "string.unquoted.yaml", "entity.name.tag.yaml", "punctuation.separator.key-value.yaml"]
    expect(lines[1][2]).toEqual value: " ", scopes: ["source.yaml", "string.unquoted.yaml"]
    expect(lines[1][3]).toEqual value: "2nd  ", scopes: ["source.yaml", "string.unquoted.yaml", "string.unquoted.yaml"]
    expect(lines[1][4]).toEqual value: "#", scopes: ["source.yaml", "comment.line.number-sign.yaml", "punctuation.definition.comment.yaml"]
    expect(lines[1][5]).toEqual value: "bar", scopes: ["source.yaml", "comment.line.number-sign.yaml"]

    expect(lines[2][0]).toEqual value: "third", scopes: ["source.yaml", "string.unquoted.yaml", "entity.name.tag.yaml"]
    expect(lines[2][1]).toEqual value: ":", scopes: ["source.yaml", "string.unquoted.yaml", "entity.name.tag.yaml", "punctuation.separator.key-value.yaml"]
    expect(lines[2][2]).toEqual value: " ", scopes: ["source.yaml", "string.unquoted.yaml"]
    expect(lines[2][3]).toEqual value: "\"", scopes: ["source.yaml", "string.unquoted.yaml", "string.quoted.double.yaml", "punctuation.definition.string.begin.yaml"]
    expect(lines[2][4]).toEqual value: "3", scopes: ["source.yaml", "string.unquoted.yaml", "string.quoted.double.yaml"]
    expect(lines[2][5]).toEqual value: "\"", scopes: ["source.yaml", "string.unquoted.yaml", "string.quoted.double.yaml", "punctuation.definition.string.end.yaml"]

    expect(lines[3][0]).toEqual value: "fourth", scopes: ["source.yaml", "string.unquoted.yaml", "entity.name.tag.yaml"]
    expect(lines[3][1]).toEqual value: ":", scopes: ["source.yaml", "string.unquoted.yaml", "entity.name.tag.yaml", "punctuation.separator.key-value.yaml"]
    expect(lines[3][2]).toEqual value: " ", scopes: ["source.yaml", "string.unquoted.yaml"]
    expect(lines[3][3]).toEqual value: "four#", scopes: ["source.yaml", "string.unquoted.yaml", "string.unquoted.yaml"]

  it "parses colons in key names", ->
    lines = grammar.tokenizeLines """
      colon::colon: 1
      colon::colon: 2nd
      colon::colon: "3"
      colon: "this is another : colon"
      colon: "this is another :colon"
    """

    expect(lines[0][0]).toEqual value: "colon::colon", scopes: ["source.yaml", "constant.numeric.yaml", "entity.name.tag.yaml"]
    expect(lines[0][1]).toEqual value: ":", scopes: ["source.yaml", "constant.numeric.yaml", "entity.name.tag.yaml", "punctuation.separator.key-value.yaml"]
    expect(lines[0][2]).toEqual value: " 1", scopes: ["source.yaml", "constant.numeric.yaml"]

    expect(lines[1][0]).toEqual value: "colon::colon", scopes: ["source.yaml", "string.unquoted.yaml", "entity.name.tag.yaml"]
    expect(lines[1][1]).toEqual value: ":", scopes: ["source.yaml", "string.unquoted.yaml", "entity.name.tag.yaml", "punctuation.separator.key-value.yaml"]
    expect(lines[1][2]).toEqual value: " ", scopes: ["source.yaml", "string.unquoted.yaml"]
    expect(lines[1][3]).toEqual value: "2nd", scopes: ["source.yaml", "string.unquoted.yaml", "string.unquoted.yaml"]

    expect(lines[2][0]).toEqual value: "colon::colon", scopes: ["source.yaml", "string.unquoted.yaml", "entity.name.tag.yaml"]
    expect(lines[2][1]).toEqual value: ":", scopes: ["source.yaml", "string.unquoted.yaml", "entity.name.tag.yaml", "punctuation.separator.key-value.yaml"]
    expect(lines[2][2]).toEqual value: " ", scopes: ["source.yaml", "string.unquoted.yaml"]
    expect(lines[2][3]).toEqual value: "\"", scopes: ["source.yaml", "string.unquoted.yaml", "string.quoted.double.yaml", "punctuation.definition.string.begin.yaml"]
    expect(lines[2][4]).toEqual value: "3", scopes: ["source.yaml", "string.unquoted.yaml", "string.quoted.double.yaml"]
    expect(lines[2][5]).toEqual value: "\"", scopes: ["source.yaml", "string.unquoted.yaml", "string.quoted.double.yaml", "punctuation.definition.string.end.yaml"]

    expect(lines[3][0]).toEqual value: "colon", scopes: ["source.yaml", "string.unquoted.yaml", "entity.name.tag.yaml"]
    expect(lines[3][1]).toEqual value: ":", scopes: ["source.yaml", "string.unquoted.yaml", "entity.name.tag.yaml", "punctuation.separator.key-value.yaml"]
    expect(lines[3][2]).toEqual value: " ", scopes: ["source.yaml", "string.unquoted.yaml"]
    expect(lines[3][3]).toEqual value: "\"", scopes: ["source.yaml", "string.unquoted.yaml", "string.quoted.double.yaml", "punctuation.definition.string.begin.yaml"]
    expect(lines[3][4]).toEqual value: "this is another : colon", scopes: ["source.yaml", "string.unquoted.yaml", "string.quoted.double.yaml"]
    expect(lines[3][5]).toEqual value: "\"", scopes: ["source.yaml", "string.unquoted.yaml", "string.quoted.double.yaml", "punctuation.definition.string.end.yaml"]

    expect(lines[4][0]).toEqual value: "colon", scopes: ["source.yaml", "string.unquoted.yaml", "entity.name.tag.yaml"]
    expect(lines[4][1]).toEqual value: ":", scopes: ["source.yaml", "string.unquoted.yaml", "entity.name.tag.yaml", "punctuation.separator.key-value.yaml"]
    expect(lines[4][2]).toEqual value: " ", scopes: ["source.yaml", "string.unquoted.yaml"]
    expect(lines[4][3]).toEqual value: "\"", scopes: ["source.yaml", "string.unquoted.yaml", "string.quoted.double.yaml", "punctuation.definition.string.begin.yaml"]
    expect(lines[4][4]).toEqual value: "this is another :colon", scopes: ["source.yaml", "string.unquoted.yaml", "string.quoted.double.yaml"]
    expect(lines[4][5]).toEqual value: "\"", scopes: ["source.yaml", "string.unquoted.yaml", "string.quoted.double.yaml", "punctuation.definition.string.end.yaml"]

  it "parses spaces in key names", ->
    lines = grammar.tokenizeLines """
      spaced out: 1
      more        spaces: 2nd
      with quotes: "3"
    """

    expect(lines[0][0]).toEqual value: "spaced out", scopes: ["source.yaml", "constant.numeric.yaml", "entity.name.tag.yaml"]
    expect(lines[0][1]).toEqual value: ":", scopes: ["source.yaml", "constant.numeric.yaml", "entity.name.tag.yaml", "punctuation.separator.key-value.yaml"]
    expect(lines[0][2]).toEqual value: " 1", scopes: ["source.yaml", "constant.numeric.yaml"]

    expect(lines[1][0]).toEqual value: "more        spaces", scopes: ["source.yaml", "string.unquoted.yaml", "entity.name.tag.yaml"]
    expect(lines[1][1]).toEqual value: ":", scopes: ["source.yaml", "string.unquoted.yaml", "entity.name.tag.yaml", "punctuation.separator.key-value.yaml"]
    expect(lines[1][2]).toEqual value: " ", scopes: ["source.yaml", "string.unquoted.yaml"]
    expect(lines[1][3]).toEqual value: "2nd", scopes: ["source.yaml", "string.unquoted.yaml", "string.unquoted.yaml"]

    expect(lines[2][0]).toEqual value: "with quotes", scopes: ["source.yaml", "string.unquoted.yaml", "entity.name.tag.yaml"]
    expect(lines[2][1]).toEqual value: ":", scopes: ["source.yaml", "string.unquoted.yaml", "entity.name.tag.yaml", "punctuation.separator.key-value.yaml"]
    expect(lines[2][2]).toEqual value: " ", scopes: ["source.yaml", "string.unquoted.yaml"]
    expect(lines[2][3]).toEqual value: "\"", scopes: ["source.yaml", "string.unquoted.yaml", "string.quoted.double.yaml", "punctuation.definition.string.begin.yaml"]
    expect(lines[2][4]).toEqual value: "3", scopes: ["source.yaml", "string.unquoted.yaml", "string.quoted.double.yaml"]
    expect(lines[2][5]).toEqual value: "\"", scopes: ["source.yaml", "string.unquoted.yaml", "string.quoted.double.yaml", "punctuation.definition.string.end.yaml"]
