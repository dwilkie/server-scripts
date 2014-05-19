# Server::Scripts

A set of useful server scripts

## Installation

Add this line to your application's Gemfile:

    gem 'server-scripts'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install server-scripts

## Configuration

### Mailer

The mailer should be configured to email alerts to the system administrator. Configuration for the mailer is done through environment variables. See [.env](https://github.com/dwilkie/server-scripts/blob/master/.env) for available configuration options.

#### Gmail

See [.env.gmail](https://github.com/dwilkie/server-scripts/blob/master/.env.gmail) for configuration options

## Usage

See the [script](https://github.com/dwilkie/server-scripts/tree/master/lib/server/script) directory

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
