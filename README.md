[![Build Status](https://travis-ci.org/GeoffWilliams/pe_rbac.svg?branch=master)](https://travis-ci.org/GeoffWilliams/pe_rbac)
# PeRbac

This gem lets you drive the Puppet Enterprise RBAC API from the command line or ruby.  While you can of-course do the same thing using the [pltraining/rbac](https://forge.puppet.com/pltraining/rbac) forge module, this requires that you have:
* Write-access to Puppet's git repository
* Code Manager setup to read from git
* A desire to continually enforce your RBAC changes

Since this is often not the case, this gem provides a command line to do things like reset passwords or setup Code Manager with a single command.

## Features/Commands
* Setup Code Manager
* Setup Read-only PuppetDB access
* Reset passwords
* Ruby API

## Installation

Gem dependencies need G++ amongst other things.  Easiest way to proceed:
```
yum groupinstall 'Development Tools'
```

Add this line to your application's Gemfile:

```ruby
gem 'pe_rbac'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pe_rbac

## Usage

### Setting up code manager on the command line
```
pe_rbac  code_manager --password t0ps3cret
```
Right now, the command line just provides a means to setup code manager.  If you
want to do more then this, you must use the Ruby API

### Generating a token to use for ro/rw access to PuppetDB API
```
# read-only access
pe_rbac puppetdb --password t0ps3cret

# read-write access
pe_rbac puppetdb --allow-write --password t0ps3cret
```

### Resetting a user password
```
pe_rbac reset_password
```
Change the password for `admin` to `changeme`

```
pe_rbac reset_password --username foo --password 12345678
```
Reset the password for the `foo` user to `12345678`

### Ruby API
A Ruby API exists, see code for more info.  For the moment this code does what I want, but may extend to cover new features as requred.


## Development

### Debugging
```
RESTCLIENT_LOG=stdout bundle exec pe_rbac
```

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/pe_rbac.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
