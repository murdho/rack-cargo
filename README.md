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

### Configuration

Initialize the middleware:

```ruby
Rack::Cargo.configure do |config|
    config.batch_path = '/batch'
end
```

Instruct `rack` to use the middleware:

```ruby
use Rack::Cargo::Middleware
```

### Referencing requests

Requests in batch have access to the responses of executed (named) requests. This is useful, when creating resources and using the reference to it in the same batch.

References can be used in `path` and `body` elements.

Example shows both usages with `order.uuid` from the `order` response:

```javascript
// This is batch request payload:
{
    "requests": [
        {
            "name": "order",
            "path": "/orders",
            "method": "POST",
            "body": {
                "address": "Home, 12345"
            }
        },
        {
            "name": "order_item",
            "path": "/orders/{{ order.uuid }}/items", // <-- here
            "method": "POST",
            "body": {
                "title": "A Book"
            }
        },
        {
            "name": "payment",
            "path": "/payments",
            "method": "POST",
            "body": {
                "orders": [
                    "{{ order.uuid }}" // <-- and here
                ]
            }
        }
    ]
}

// This is a possible response:
[
    {
        "name": "order", // <-- "order" part of "order.uuid"
        "status": 201,
        "headers": {},
        "body": {
            "uuid": "bf52fdb5-d1c3-4c66-ba7d-bdf4cd83f265", // <-- "uuid" part of "order.uuid"
            "address": "Home, 12345"
        }
    },
    {
        "name": "order_item",
        "status": 201,
        "headers": {},
        "body": {
            "uuid": "38bc4576-3b7e-40be-a1d6-ca795fe462c8",
            "title": "A Book"
        }
    },
    {
        "name": "payment",
        "status": 201,
        "headers": {},
        "body": {
            "uuid": "c4f9f261-7822-4217-80a2-06cf92934bf9",
            "orders": [
                "bf52fdb5-d1c3-4c66-ba7d-bdf4cd83f265"
            ]
        }
    }
]
```

### Modifying batch processing pipeline

Batch processing is composed of steps that perform some concrete action on the request and/or state of the processing.

To insert processor in the pipeline, define the processor and inject it to the processors list:

```ruby
module MyFeeder
  def self.call(request, state)
    # calculate something
    state.store(:data, "Useful data to MyEater")
  end
end
 
module MyEater
  def self.call(request, state)
    data = state.fetch(:data)
    # do something with the data
  end
end
 
Rack::Cargo.configure do |config|
  config.processors.insert(2, MyFeeder) # insert into third position
  config.processors.insert(3, MyEater) # insert into fourth position
end
```

Now your processors will be included in the pipeline.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/rack-cargo. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Rack::Cargo project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/rack-cargo/blob/master/CODE_OF_CONDUCT.md).
