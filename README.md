# Nude

Port of [nude.js][nudejs] to Ruby.

[nudejs]: http://www.patrick-wied.at/static/nudejs/

## Requirements

* ImageMagick

## Installation

Add this line to your application's Gemfile:

    gem 'nude'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nude

## Usage

```ruby
puts Nude.nude?('/path/to/image1.jpg')
# => true

n = Nude.parse('/path/to/image2.jpg')
puts n.nude?
# => false
puts n.inspect
# => #<Nude @result=false, @message="Total skin parcentage lower than 15 (10%)", @image=/path/to/image2.jpg JPEG 500x375 500x375+0+0 DirectClass 8-bit 108kb>
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Copyright

Copyright (c) 2012 [Kazuya Takeshima](mailto:mail@mitukiii.jp). See [LICENSE][license] for details.

[license]: LICENSE.md
