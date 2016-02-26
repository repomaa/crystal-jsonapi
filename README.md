# JSONApi [![Build Status](https://travis-ci.org/jreinert/crystal-jsonapi.svg?branch=master)](https://travis-ci.org/jreinert/crystal-jsonapi)

[JSON API](http://jsonapi.org) Serializers for Crystal

## Features

- Easy serialization of basic JSON API objects
- Built in caching support

## Performance

JSONApi is very fast. Thanks to the built in caching support it outperforms
vanilla .to_json by almost an order of magnitude. See the following graphic.

![Performance plot](https://cdn.rawgit.com/jreinert/crystal-jsonapi/master/examples/collections.svg)

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  json_api:
    github: jreinert/crystal-jsonapi
```


## Usage

See [examples/people.cr](examples/people.cr) for a real-world example and
[examples/people.out.json](examples/people.out.json) for the generated output.


## Contributing

1. Fork it ( https://github.com/jreinert/crystal-jsonapi/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [jreinert](https://github.com/jreinert) Joakim Reinert - creator, maintainer
