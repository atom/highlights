path = require 'path'
fs = require 'fs-plus'
CSON = require 'season'
once = require 'once'
{GrammarRegistry} = require 'first-mate'
Selector = require 'first-mate-select-grammar'
selector = Selector()
TokensToHTML = require './tokens-to-html'


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
    @_loadingGrammars = false

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

    @_highlightCommon({filePath, fileContents, scopeName})

  # Public: Syntax highlight the given file asyncronously
  #
  # options - An Object with the following keys:
  #   :fileContents - The optional String contents of the file. The file will
  #                   be read from disk if this is unspecified
  #   :filePath     - The String path to the file.
  #   :scopeName    - An optional String scope name of a grammar. The best match
  #                   grammar will be used if this is unspecified.
  #
  # cb - A callback with the highlighted html or error
  #
  # Calls back with a string of HTML. The HTML will contains one <pre> with one <div>
  # per line and each line will contain one or more <span> elements for the
  # tokens in the line. All grammar loading and fs operations are async so you can use this module in a server or busy process.
  highlight: ({filePath, fileContents, scopeName}={},cb) ->


    @loadGrammars (err) =>
      return cb(err) if err

      if filePath and !fileContents
        fs.readFile filePath, 'utf8', (err,fileContents) =>
          return cb(err) if err
          cb(false,@_highlightCommon({filePath, fileContents, scopeName}))
      else
        cb(false,@_highlightCommon({filePath, fileContents, scopeName}))

  # Public: Require all the grammars from the grammars folder at the root of an
  #   npm module.
  #
  # modulePath - the String path to the module to require grammars from. If the
  #              given path is a file then the grammars folder from the parent
  #              directory will be used.
  requireGrammarsSync: ({modulePath}={}) ->
    @loadGrammarsSync()

    if fs.isFileSync(modulePath)
      packageDir = path.dirname(modulePath)
    else
      packageDir = modulePath

    grammarsDir = path.resolve(packageDir, 'grammars')

    return unless fs.isDirectorySync(grammarsDir)

    for file in fs.readdirSync(grammarsDir)
      if grammarPath = CSON.resolve(path.join(grammarsDir, file))
        @registry.loadGrammarSync(grammarPath)

    return

  # Public: Require all the grammars from the grammars folder at the root of an
  #   npm module asyncronously.
  #
  # {modulePath} - the String path to the module to require grammars from. If the
  #              given path is a file then the grammars folder from the parent
  #              directory will be used.
  # cb(err) - The callback so you know when it's done
  #
  requireGrammars: ({modulePath}={},cb) ->
    @loadGrammars (err) =>
      return cb(err) if err

      fs.stat modulePath, (err, stat) =>
        return cb(err) if err

        if stat.isFile()
          packageDir = path.dirname(modulePath)
        else if stat.isDirectory()
          packageDir = modulePath
        else
          # return with no error at all if i cant find the module dir.
          return cb()

        grammarsDir = path.resolve(packageDir, 'grammars')
        @_registryLoadGrammarsDir(grammarsDir,cb)

  _registryLoadGrammarsDir: (dir,cb) ->
    cb = once(cb)
    todo = false
    done = (err) ->
      return cb(err) if err
      cb() unless --todo

    fs.readdir dir, (err, files) =>
      if err
        return cb(err)

      todo = files.length
      return cb(false,[]) unless todo

      while files.length
        file = files.shift()
        grammarPath = path.join(dir, file)
        # CSON.resolve uses fs.isFileSync we'll have to check it in the next step but only on valid files.
        if CSON.isObjectPath(grammarPath)
          @_registryLoadGrammar grammarPath, (err) -> done(err)

  _registryLoadGrammar: (grammarPath,cb) ->
    fs.stat grammarPath,(err,stat) =>
      return cb(err) if err

      # does not error out at this stage if the file is named like a grammar but is not a file.
      return cb() if !stat.isFile()

      @registry.loadGrammar(grammarPath,cb)

  _highlightCommon: ({filePath, fileContents, scopeName}={}) ->

    grammar = @registry.grammarForScopeName(scopeName)
    grammar ?= selector.selectGrammar(@registry, filePath, fileContents)

    lineTokens = grammar.tokenizeLines(fileContents)
    TokensToHTML.highlightFromTokens(lineTokens)

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

    return

  loadGrammars: (cb) ->
    cb = once(cb)

    if @_loadingGrammars == true or @registry.grammars.length > 1
      return setImmediate(cb)
    else if Array.isArray(@_loadingGrammars)
      return @_loadingGrammars.push(cb)

    @_loadingGrammars = [cb]
    callbacks = (err) =>

      cbs = @_loadingGrammars
      @_loadingGrammars = true
      while cbs.length
        cbs.shift()(err)

    pendingAsyncCalls = 2
    grammarsFromJSON = null
    grammarsArray = null

    done = (err,paths) =>
      return callbacks(err) if err
      if !--pendingAsyncCalls
        @_populateGrammars(grammarsFromJSON, grammarsArray, callbacks)

    @_findGrammars (err,arr) ->
      grammarsArray = arr
      done(err)

    @_loadGrammarsJSON (err,fromJSON) ->
      grammarsFromJSON = fromJSON
      done(err)

  _populateGrammars: (grammarsFromJSON,grammarsArray,cb) ->
    toLoad = (grammarsArray||[]).length
    grammars = []

    done = (err,grammar) =>
      return cb(err) if err

      grammars.push(grammar) if grammar

      if !--toLoad
        # complete loading from grammars.json
        for grammarPath, grammar of grammarsFromJSON
          continue if @registry.grammarForScopeName(grammar.scopeName)?
          grammar = @registry.createGrammar(grammarPath, grammar)
          @registry.addGrammar(grammar)

        cb(false,true)

    if !toLoad
      toLoad = 1
      return done()

    while grammarsArray.length
      @registry.loadGrammar(grammarsArray.shift(),done)

  _findGrammars: (cb) ->
    if typeof @includePath is 'string'
      fs.stat @includePath, (err, stat) =>
        return cb(err) if err
        if stat.isFile()
          cb(false,[@includePath])
        else if stat.isDirectory()
          fs.list @includePath,['cson','json'], (err,list=[]) -> cb(err,list)
        else
          cb(new Error('unsupported file type.'))
    else
      setImmediate(cb)

  _loadGrammarsJSON: (cb) ->
    grammarsPath = path.join(__dirname, '..', 'gen', 'grammars.json')
    fs.readFile grammarsPath, (err,contents) ->
      try
        cb(false, JSON.parse(contents))
      catch err
        return cb(err)
