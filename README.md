# Rack::Cargo

Have you built nice RESTful APIs? I believe you have.

Then you are also familiar with the situation, where API consumer needs to perform multiple actions at once. Maybe in the client application, multiple resources get created on one page. Creating multiple resources means making multiple HTTP requests.

What if you could **batch the requests** together and send in one HTTP requests, wouldn't that be more efficient? I believe it would be! That's where **Rack::Cargo** comes in.

Figuratively speaking, load your HTTP-request ship with the request cargo and put it on the way and enjoy your RESTful API! ☀️

> ***You:** I want to know more about RESTful. Where should I look?*
>
> ***Me:** Cool! I recommend this awesome talk: [In Relentless Pursuit of REST by Derek Prior](https://youtu.be/HctYHe-YjnE)*

## Installation

Add this line to your Rack-based application's (Rails, Sinatra, etc.) Gemfile:

```ruby
gem 'rack-cargo'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-cargo

## Usage (TODO)

- Configure
- ...
- Profit!

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/rack-cargo. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Rack::Cargo project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/rack-cargo/blob/master/CODE_OF_CONDUCT.md).
