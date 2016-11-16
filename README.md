# PeRbac

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/pe_rbac`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

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

### Ruby API
An *IN FLUX* Ruby API exists, see code for more info.  This WILL change (well it 
will if I do any more development work on this...) - expect module names, 
functions, etc. to change.  In particular, I'm planning:
* Sub-modules/file reorgs
* tests!

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

