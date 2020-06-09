# musicapp

`musicapp` is a command to control Apple's Music.app.
Now, this supports following.

* Get metadata of selected tracks as JSON.
* Set metadata of selected tracks by JSON.
* Play, Pause, and skip to next track.

## Installation

    $ gem install musicapp

Or

    $ git clone https://github.com/labocho/musicapp.git
    $ cd musicapp
    $ bundle install
    $ bundle exec rake install

## Usage

    # Show help
    $ musicapp help

    # Play, Pause, Skip to next track
    $ musicapp play
    $ musicapp stop
    $ musicapp skip

    # Get metadata of selected tracks
    $ musicapp get --field name,trackNumber
    {"name":"Hello, World!","trackNumber":12}
    {"name":"foobar","trackNumber":13}

    # Set metadata of selected tracks
    $ cat <<EOS | musicapp set
    {"name":"Hello, World!!!","trackNumber":11}
    {"name":"foobar!!","trackNumber":12}
    EOS

    # List available metadata fields
    $ musicapp fields
    album
    albumArtist
    albumDisliked
    ...

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/musicapp.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
