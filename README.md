# SignedActiveresource

A simple gem that lets you hook into an ActiveResource's request to sign the request before it goes out.

## Installation

Add this line to your application's Gemfile:

    gem 'signed_activeresource'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install signed_activeresource

## Usage

Instead of subclassing `ActiveResource::Base`, subclass `SignedActiveResource::Base` and set the `request_signer` class attribute.

	class Person < SignedActiveResource::Base
		self.request_signer = signer # an object that responds to sign_request!(http_request)
	end

The use case that motivated it is using OAuth, so in that case your request_signer is an instance of
`OAuth::AccessToken` which will take care of signing things for you.

## Before you hate

`ActiveResource` already has a dependency on `ActiveSupport` so don't hate on me, I didn't introduce the dependency. The only time I use it is to 
inflect some strings. No, I'm not doing a `require 'active_support/all'`!

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
