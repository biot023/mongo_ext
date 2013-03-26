# mongoExt



## Installation

Add this line to your application's Gemfile:

    gem "mongo_ext", :git => "git@github.com:biot023/mongo_ext.git"

And then execute:

    $ bundle

## Usage

require "b23/mongo_ext"

Really simple wrappers over collections, allowing to try operations, then attempt a reconnect
and try again in the case of mongo errors. Can access the client, db, and collection, but there
is a check each time to see if the client is connected. Useful for exactly nobody but me, I
rather suspect.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
