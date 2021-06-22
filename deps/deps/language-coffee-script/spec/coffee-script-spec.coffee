describe "CoffeeScript grammar", ->
  grammar = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage("language-coffee-script")

    runs ->
      grammar = atom.grammars.grammarForScopeName("source.coffee")

  it "parses the grammar", ->
    expect(grammar).toBeTruthy()
    expect(grammar.scopeName).toBe "source.coffee"

  it "tokenizes classes", ->
    {tokens} = grammar.tokenizeLine("class Foo")

    expect(tokens[0]).toEqual value: "class", scopes: ["source.coffee", "meta.class.coffee", "storage.type.class.coffee"]
    expect(tokens[1]).toEqual value: " ", scopes: ["source.coffee", "meta.class.coffee"]
    expect(tokens[2]).toEqual value: "Foo", scopes: ["source.coffee", "meta.class.coffee", "entity.name.type.class.coffee"]

    {tokens} = grammar.tokenizeLine("subclass Foo")
    expect(tokens[0]).toEqual value: "subclass Foo", scopes: ["source.coffee"]

    {tokens} = grammar.tokenizeLine("[class Foo]")
    expect(tokens[0]).toEqual value: "[", scopes: ["source.coffee", "meta.brace.square.coffee"]
    expect(tokens[1]).toEqual value: "class", scopes: ["source.coffee", "meta.class.coffee", "storage.type.class.coffee"]
    expect(tokens[2]).toEqual value: " ", scopes: ["source.coffee", "meta.class.coffee"]
    expect(tokens[3]).toEqual value: "Foo", scopes: ["source.coffee", "meta.class.coffee", "entity.name.type.class.coffee"]
    expect(tokens[4]).toEqual value: "]", scopes: ["source.coffee", "meta.brace.square.coffee"]

    {tokens} = grammar.tokenizeLine("bar(class Foo)")
    expect(tokens[0]).toEqual value: "bar", scopes: ["source.coffee"]
    expect(tokens[1]).toEqual value: "(", scopes: ["source.coffee", "meta.brace.round.coffee"]
    expect(tokens[2]).toEqual value: "class", scopes: ["source.coffee", "meta.class.coffee", "storage.type.class.coffee"]
    expect(tokens[3]).toEqual value: " ", scopes: ["source.coffee", "meta.class.coffee"]
    expect(tokens[4]).toEqual value: "Foo", scopes: ["source.coffee", "meta.class.coffee", "entity.name.type.class.coffee"]
    expect(tokens[5]).toEqual value: ")", scopes: ["source.coffee", "meta.brace.round.coffee"]

  it "tokenizes named subclasses", ->
    {tokens} = grammar.tokenizeLine("class Foo extends Bar")

    expect(tokens[0]).toEqual value: "class", scopes: ["source.coffee", "meta.class.coffee", "storage.type.class.coffee"]
    expect(tokens[1]).toEqual value: " ", scopes: ["source.coffee", "meta.class.coffee"]
    expect(tokens[2]).toEqual value: "Foo", scopes: ["source.coffee", "meta.class.coffee", "entity.name.type.class.coffee"]
    expect(tokens[3]).toEqual value: " ", scopes: ["source.coffee", "meta.class.coffee"]
    expect(tokens[4]).toEqual value: "extends", scopes: ["source.coffee", "meta.class.coffee", "keyword.control.inheritance.coffee"]
    expect(tokens[5]).toEqual value: " ", scopes: ["source.coffee", "meta.class.coffee"]
    expect(tokens[6]).toEqual value: "Bar", scopes: ["source.coffee", "meta.class.coffee", "entity.other.inherited-class.coffee"]

  it "tokenizes anonymous subclasses", ->
    {tokens} = grammar.tokenizeLine("class extends Foo")

    expect(tokens[0]).toEqual value: "class", scopes: ["source.coffee", "meta.class.coffee", "storage.type.class.coffee"]
    expect(tokens[1]).toEqual value: " ", scopes: ["source.coffee", "meta.class.coffee"]
    expect(tokens[2]).toEqual value: "extends", scopes: ["source.coffee", "meta.class.coffee", "keyword.control.inheritance.coffee"]
    expect(tokens[3]).toEqual value: " ", scopes: ["source.coffee", "meta.class.coffee"]
    expect(tokens[4]).toEqual value: "Foo", scopes: ["source.coffee", "meta.class.coffee", "entity.other.inherited-class.coffee"]

  it "tokenizes instantiated anonymous classes", ->
    {tokens} = grammar.tokenizeLine("new class")

    expect(tokens[0]).toEqual value: "new", scopes: ["source.coffee", "meta.class.instance.constructor", "keyword.operator.new.coffee"]
    expect(tokens[1]).toEqual value: " ", scopes: ["source.coffee", "meta.class.instance.constructor"]
    expect(tokens[2]).toEqual value: "class", scopes: ["source.coffee", "meta.class.instance.constructor", "storage.type.class.coffee"]

  it "tokenizes instantiated named classes", ->
    {tokens} = grammar.tokenizeLine("new class Foo")

    expect(tokens[0]).toEqual value: "new", scopes: ["source.coffee", "meta.class.instance.constructor", "keyword.operator.new.coffee"]
    expect(tokens[1]).toEqual value: " ", scopes: ["source.coffee", "meta.class.instance.constructor"]
    expect(tokens[2]).toEqual value: "class", scopes: ["source.coffee", "meta.class.instance.constructor", "storage.type.class.coffee"]
    expect(tokens[3]).toEqual value: " ", scopes: ["source.coffee", "meta.class.instance.constructor"]
    expect(tokens[4]).toEqual value: "Foo", scopes: ["source.coffee", "meta.class.instance.constructor", "entity.name.type.instance.coffee"]

    {tokens} = grammar.tokenizeLine("new Foo")

    expect(tokens[0]).toEqual value: "new", scopes: ["source.coffee", "meta.class.instance.constructor", "keyword.operator.new.coffee"]
    expect(tokens[1]).toEqual value: " ", scopes: ["source.coffee", "meta.class.instance.constructor"]
    expect(tokens[2]).toEqual value: "Foo", scopes: ["source.coffee", "meta.class.instance.constructor", "entity.name.type.instance.coffee"]

  it "tokenizes annotations in block comments", ->
    lines = grammar.tokenizeLines """
      ###
        @foo - food
      @bar - bart
      """

    expect(lines[1][0]).toEqual value: '  ', scopes: ["source.coffee", "comment.block.coffee"]
    expect(lines[1][1]).toEqual value: '@foo', scopes: ["source.coffee", "comment.block.coffee", "storage.type.annotation.coffee"]
    expect(lines[2][0]).toEqual value: '@bar', scopes: ["source.coffee", "comment.block.coffee", "storage.type.annotation.coffee"]

  it "tokenizes this as a special variable", ->
    {tokens} = grammar.tokenizeLine("this")

    expect(tokens[0]).toEqual value: "this", scopes: ["source.coffee", "variable.language.this.coffee"]

  it "tokenizes variable assignments", ->
    {tokens} = grammar.tokenizeLine("a = b")
    expect(tokens[0]).toEqual value: "a ", scopes: ["source.coffee", "variable.assignment.coffee", "variable.assignment.coffee"]
    expect(tokens[1]).toEqual value: "=", scopes: ["source.coffee", "variable.assignment.coffee", "variable.assignment.coffee", "keyword.operator.coffee"]
    expect(tokens[2]).toEqual value: " b", scopes: ["source.coffee"]

    {tokens} = grammar.tokenizeLine("a and= b")
    expect(tokens[0]).toEqual value: "a ", scopes: ["source.coffee", "variable.assignment.coffee", "variable.assignment.coffee"]
    expect(tokens[1]).toEqual value: "and=", scopes: ["source.coffee", "variable.assignment.coffee", "variable.assignment.coffee", "keyword.operator.coffee"]
    expect(tokens[2]).toEqual value: " b", scopes: ["source.coffee"]

    {tokens} = grammar.tokenizeLine("a or= b")
    expect(tokens[0]).toEqual value: "a ", scopes: ["source.coffee", "variable.assignment.coffee", "variable.assignment.coffee"]
    expect(tokens[1]).toEqual value: "or=", scopes: ["source.coffee", "variable.assignment.coffee", "variable.assignment.coffee", "keyword.operator.coffee"]
    expect(tokens[2]).toEqual value: " b", scopes: ["source.coffee"]

    {tokens} = grammar.tokenizeLine("a -= b")
    expect(tokens[0]).toEqual value: "a ", scopes: ["source.coffee", "variable.assignment.coffee", "variable.assignment.coffee"]
    expect(tokens[1]).toEqual value: "-=", scopes: ["source.coffee", "variable.assignment.coffee", "variable.assignment.coffee", "keyword.operator.coffee"]
    expect(tokens[2]).toEqual value: " b", scopes: ["source.coffee"]

    {tokens} = grammar.tokenizeLine("a += b")
    expect(tokens[0]).toEqual value: "a ", scopes: ["source.coffee", "variable.assignment.coffee", "variable.assignment.coffee"]
    expect(tokens[1]).toEqual value: "+=", scopes: ["source.coffee", "variable.assignment.coffee", "variable.assignment.coffee", "keyword.operator.coffee"]
    expect(tokens[2]).toEqual value: " b", scopes: ["source.coffee"]

    {tokens} = grammar.tokenizeLine("a /= b")
    expect(tokens[0]).toEqual value: "a ", scopes: ["source.coffee", "variable.assignment.coffee", "variable.assignment.coffee"]
    expect(tokens[1]).toEqual value: "/=", scopes: ["source.coffee", "variable.assignment.coffee", "variable.assignment.coffee", "keyword.operator.coffee"]
    expect(tokens[2]).toEqual value: " b", scopes: ["source.coffee"]

    {tokens} = grammar.tokenizeLine("a &= b")
    expect(tokens[0]).toEqual value: "a ", scopes: ["source.coffee", "variable.assignment.coffee", "variable.assignment.coffee"]
    expect(tokens[1]).toEqual value: "&=", scopes: ["source.coffee", "variable.assignment.coffee", "variable.assignment.coffee", "keyword.operator.coffee"]
    expect(tokens[2]).toEqual value: " b", scopes: ["source.coffee"]

    {tokens} = grammar.tokenizeLine("a %= b")
    expect(tokens[0]).toEqual value: "a ", scopes: ["source.coffee", "variable.assignment.coffee", "variable.assignment.coffee"]
    expect(tokens[1]).toEqual value: "%=", scopes: ["source.coffee", "variable.assignment.coffee", "variable.assignment.coffee", "keyword.operator.coffee"]
    expect(tokens[2]).toEqual value: " b", scopes: ["source.coffee"]

    {tokens} = grammar.tokenizeLine("a *= b")
    expect(tokens[0]).toEqual value: "a ", scopes: ["source.coffee", "variable.assignment.coffee", "variable.assignment.coffee"]
    expect(tokens[1]).toEqual value: "*=", scopes: ["source.coffee", "variable.assignment.coffee", "variable.assignment.coffee", "keyword.operator.coffee"]
    expect(tokens[2]).toEqual value: " b", scopes: ["source.coffee"]

    {tokens} = grammar.tokenizeLine("a ?= b")
    expect(tokens[0]).toEqual value: "a ", scopes: ["source.coffee", "variable.assignment.coffee", "variable.assignment.coffee"]
    expect(tokens[1]).toEqual value: "?=", scopes: ["source.coffee", "variable.assignment.coffee", "variable.assignment.coffee", "keyword.operator.coffee"]
    expect(tokens[2]).toEqual value: " b", scopes: ["source.coffee"]

    {tokens} = grammar.tokenizeLine("a == b")
    expect(tokens[0]).toEqual value: "a ", scopes: ["source.coffee"]
    expect(tokens[1]).toEqual value: "==", scopes: ["source.coffee", "keyword.operator.coffee"]
    expect(tokens[2]).toEqual value: " b", scopes: ["source.coffee"]

    {tokens} = grammar.tokenizeLine("false == b")
    expect(tokens[0]).toEqual value: "false", scopes: ["source.coffee", "constant.language.boolean.false.coffee"]
    expect(tokens[1]).toEqual value: " ", scopes: ["source.coffee"]
    expect(tokens[2]).toEqual value: "==", scopes: ["source.coffee", "keyword.operator.coffee"]
    expect(tokens[3]).toEqual value: " b", scopes: ["source.coffee"]

    {tokens} = grammar.tokenizeLine("true == b")
    expect(tokens[0]).toEqual value: "true", scopes: ["source.coffee", "constant.language.boolean.true.coffee"]
    expect(tokens[1]).toEqual value: " ", scopes: ["source.coffee"]
    expect(tokens[2]).toEqual value: "==", scopes: ["source.coffee", "keyword.operator.coffee"]
    expect(tokens[3]).toEqual value: " b", scopes: ["source.coffee"]

    {tokens} = grammar.tokenizeLine("null == b")
    expect(tokens[0]).toEqual value: "null", scopes: ["source.coffee", "constant.language.null.coffee"]
    expect(tokens[1]).toEqual value: " ", scopes: ["source.coffee"]
    expect(tokens[2]).toEqual value: "==", scopes: ["source.coffee", "keyword.operator.coffee"]
    expect(tokens[3]).toEqual value: " b", scopes: ["source.coffee"]

    {tokens} = grammar.tokenizeLine("this == b")
    expect(tokens[0]).toEqual value: "this", scopes: ["source.coffee", "variable.language.this.coffee"]
    expect(tokens[1]).toEqual value: " ", scopes: ["source.coffee"]
    expect(tokens[2]).toEqual value: "==", scopes: ["source.coffee", "keyword.operator.coffee"]
    expect(tokens[3]).toEqual value: " b", scopes: ["source.coffee"]

  it "does not confuse prototype properties with constants and keywords", ->
    {tokens} = grammar.tokenizeLine("Foo::true")
    expect(tokens[0]).toEqual value: "Foo", scopes: ["source.coffee"]
    expect(tokens[1]).toEqual value: ":", scopes: ["source.coffee", "keyword.operator.coffee"]
    expect(tokens[2]).toEqual value: ":", scopes: ["source.coffee", "keyword.operator.coffee"]
    expect(tokens[3]).toEqual value: "true", scopes: ["source.coffee"]

    {tokens} = grammar.tokenizeLine("Foo::on")
    expect(tokens[0]).toEqual value: "Foo", scopes: ["source.coffee"]
    expect(tokens[1]).toEqual value: ":", scopes: ["source.coffee", "keyword.operator.coffee"]
    expect(tokens[2]).toEqual value: ":", scopes: ["source.coffee", "keyword.operator.coffee"]
    expect(tokens[3]).toEqual value: "on", scopes: ["source.coffee"]

    {tokens} = grammar.tokenizeLine("Foo::yes")
    expect(tokens[0]).toEqual value: "Foo", scopes: ["source.coffee"]
    expect(tokens[1]).toEqual value: ":", scopes: ["source.coffee", "keyword.operator.coffee"]
    expect(tokens[2]).toEqual value: ":", scopes: ["source.coffee", "keyword.operator.coffee"]
    expect(tokens[3]).toEqual value: "yes", scopes: ["source.coffee"]

    {tokens} = grammar.tokenizeLine("Foo::false")
    expect(tokens[0]).toEqual value: "Foo", scopes: ["source.coffee"]
    expect(tokens[1]).toEqual value: ":", scopes: ["source.coffee", "keyword.operator.coffee"]
    expect(tokens[2]).toEqual value: ":", scopes: ["source.coffee", "keyword.operator.coffee"]
    expect(tokens[3]).toEqual value: "false", scopes: ["source.coffee"]

    {tokens} = grammar.tokenizeLine("Foo::off")
    expect(tokens[0]).toEqual value: "Foo", scopes: ["source.coffee"]
    expect(tokens[1]).toEqual value: ":", scopes: ["source.coffee", "keyword.operator.coffee"]
    expect(tokens[2]).toEqual value: ":", scopes: ["source.coffee", "keyword.operator.coffee"]
    expect(tokens[3]).toEqual value: "off", scopes: ["source.coffee"]

    {tokens} = grammar.tokenizeLine("Foo::no")
    expect(tokens[0]).toEqual value: "Foo", scopes: ["source.coffee"]
    expect(tokens[1]).toEqual value: ":", scopes: ["source.coffee", "keyword.operator.coffee"]
    expect(tokens[2]).toEqual value: ":", scopes: ["source.coffee", "keyword.operator.coffee"]
    expect(tokens[3]).toEqual value: "no", scopes: ["source.coffee"]

    {tokens} = grammar.tokenizeLine("Foo::null")
    expect(tokens[0]).toEqual value: "Foo", scopes: ["source.coffee"]
    expect(tokens[1]).toEqual value: ":", scopes: ["source.coffee", "keyword.operator.coffee"]
    expect(tokens[2]).toEqual value: ":", scopes: ["source.coffee", "keyword.operator.coffee"]
    expect(tokens[3]).toEqual value: "null", scopes: ["source.coffee"]

    {tokens} = grammar.tokenizeLine("Foo::extends")
    expect(tokens[0]).toEqual value: "Foo", scopes: ["source.coffee"]
    expect(tokens[1]).toEqual value: ":", scopes: ["source.coffee", "keyword.operator.coffee"]
    expect(tokens[2]).toEqual value: ":", scopes: ["source.coffee", "keyword.operator.coffee"]
    expect(tokens[3]).toEqual value: "extends", scopes: ["source.coffee"]
