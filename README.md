# url-diff

We primarily use this for debugging VAST requests to make it easy to see the difference when macros and such are compiled, which is otherwise a pain.  This is writtien in [Crystal](https://github.com/crystal-lang/crystal) so there is currently no support for Windows environments.

[![Build Status](https://travis-ci.org/flowplayer/url-diff.cr.svg?branch=master)](https://travis-ci.org/flowplayer/url-diff.cr)

diff two urls by:
1. hostname
2. path
3. query parameters

## Installation

download the binary and add it to your `$PATH` from the releases page, or if you are familiar with Crystal, you can build the binaries from this repo using `shards build url-diff`

## Usage

`url-diff help`

## Contributing

1. Fork it (<https://github.com/flowplayer/url-diff/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Benjamin Clos](https://github.com/ondreian) - creator and maintainer
