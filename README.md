![](https://f.cloud.github.com/assets/671378/2454103/24d89962-aee6-11e3-9dcf-ee2d81ec0373.jpg)

Reads in code, writes out HTML with CSS classes based on the tokens in the code.

[![Build Status](https://travis-ci.org/atom/highlights.png)](https://travis-ci.org/atom/highlights)

See it in action [here](http://atom.github.io/highlights/examples).

### Installing

```sh
npm install highlights
```

### Using

To convert a source file to tokenized HTML run the following:

```sh
highlights file.coffee -o file.html
```

Now you have a `file.html` file that has a big `<pre>` tag with a `<div>` for
each line with `<span>` elements for each token.

Then you can compile an existing Atom theme into a stylesheet with the
following:

```sh
git clone https://github.com/atom/atom-dark-syntax
cd atom-dark-syntax
npm install -g less
lessc --include-path=stylesheets index.less atom-dark-syntax.css
```

Now you have an `atom-dark-syntax.css` stylesheet that be combined with
the `file.html` file to generate some nice looking code.

Check out the [examples](http://atom.github.io/highlights/examples) to see
it in action.

Check out [atom.io](https://atom.io/packages) to find more themes.

Run `highlights -h` for full details about the supported options.

### Developing

* Close this repository
* Run `npm install`
* Run `npm test` to run the specs

:green_heart: Pull requests are greatly appreciated and welcomed.
