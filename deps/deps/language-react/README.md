[![Build Status](https://travis-ci.org/orktes/atom-react.svg?branch=master)](https://travis-ci.org/orktes/atom-react)

# Atom React.js support

Visit [orktes.github.io/atom-react](https://orktes.github.io/atom-react) for more information.

# Changelog (notable changes)

## v0.16.2 (29 December 2016)
- Fix highlighting issues caused by ternary operations and other `?` after updating to atom 0.12.7

## v0.16.1 (11 October 2016)
- Fix Atom 0.11 `TypeError: this.getRegexForProperty is not a function` error (restart atom after update)

## v0.16.0 (7 August 2016)
- Fix issues related to Atom versions newer than 1.8.0

## v0.15 (30 March 2016)
- Pump minor version to see if it helps with APM issue https://github.com/atom/apm/issues/529

## v0.14.2 (20 March 2016)
- Fix yet another regression caused by atom update. This time both rendering inside parenthesis and in function/method call arguments.
- Add required semicolon to static class properties snippet

## v0.14.1 (18 January 2016)
- Fix issue that caused `return (...);` to be tokenized as a function call.

## 0.14 (15 January 2016)
- Fixes related syntax highlighting inside functions and methods in atom 1.4

## 0.11 (5 April 2015)
- Closing tag auto-completion [in action](https://cloud.githubusercontent.com/assets/606347/6997161/28412172-dbb9-11e4-9719-2d58b0b79b3f.gif)

## Features

- Syntax highlighting
- Snippets
- Automatic indentation and folding
- JSX Reformatting
- HTML to JSX conversion
- Autocomplete

Contributions are greatly appreciated. Please fork this repository and open a pull request to add snippets, make grammar tweaks, etc.

Initially a port of [sublime-react](https://github.com/reactjs/sublime-react) for [Atom](https://github.com/atom/atom).
