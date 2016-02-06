# Ulysses

This is a library to export your to HTML files. It still in development.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ulysses'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ulysses

## Usage

Get your library:

    library = Ulysses::Library.new
    
Get groups from library

    groups = library.groups
    
Get children groups:

    group = library.groups.first
    children = group.children
    
Get Sheets:

    group.sheets
    
Export sheet to HTML:

    sheet = group.sheets.first
    html  = sheet.to_html

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yaodong/gem-ulysses. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
