# Ecoji.rb

[Ecoji](https://ecoji.io) is a data-to-emoji encoding scheme.
This library provides the implementation of Ecoji in Ruby.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ecoji'
```

And then execute:

```console
$ bundle
```

Or install it yourself as:

```console
$ gem install ecoji
```

## Usage

```ruby
require 'ecoji'

Ecoji.encode("Base64 is so 1999, isn't there something better?")
# => "🧏📩🧈🐇🧅📘🔯🚜💞😽♏🐊🎱🥁🚄🌱💞😭💮✊💢🪠🐭🩴🍉🚲🦑🐶💢🪠🔮🩹🍉📸🐮🌼👦🚟🥰☕"

Ecoji.decode("🧏📩🧈🐇🧅📘🔯🚜💞😽♏🐊🎱🥁🚄🌱💞😭💮✊💢🪠🐭🩴🍉🚲🦑🐶💢🪠🔮🩹🍉📸🐮🌼👦🚟🥰☕")
# => "Base64 is so 1999, isn't there something better?"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/MakeNowJust/ecoji. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

Note that this source code is derived from [the original implementation](https://github.com/keith-turner/ecoji).
Thus, we copied the LICENSE of Ecoji to `LICENSE.ecoji`.
Thanks for the great implementation!

## Code of Conduct

Everyone interacting in the Ecoji project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/makenowjust/ecoji.rb/blob/master/CODE_OF_CONDUCT.md).
