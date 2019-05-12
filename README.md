# SimplifyApi

Simplify the use of APIs in Ruby.

The simplicity is really that you can define your API as Ruby classes, and throwing in a JSON string you'll have all your objects created.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'simplify_api'
```

And then execute:

    $ bundle

## Usage


```ruby
require 'simplify_api'

class Options
  include SimplifyApi
  attribute :key, String, mandatory: true
  attribute :value, String, mandatory: true
end

class ServiceDescription
  include SimplifyApi
  attribute :service_id, Integer, mandatory: true
  attribute :services, [String]
end

class ApiCallParameters
  include SimplifyApi
  attribute :id, Integer, mandatory: true
  attribute :name, String
  attribute :gender, String, values: ["Male", "Female", "Other"]
  attribute :email, String
  attribute :options, [Options]
  attribute :service_description, ServiceDescription
end

api_parameters = ApiCallParameters.new id: 1, name: "MyApi", options: [{key: "Create", value: "/api/create"}, {key: "Update", value: "/api/update"}], service_description: {service_id: 1, services: ["Create", "Update"]}
# => #<ApiCallParameters:0x0000000002b09ff8 @id=1, @name="MyApi", @options=[#<Options:0x0000000002b09670 @key="Create", @value="/api/create">, #<Options:0x0000000002b08608 @key="Update", @value="/api/update">], @service_description=#<ServiceDescription:0x0000000002b07aa0 @service_id=1, @services=["Create", "Update"]>>

api_parameters.to_h
# => {:id=>1, :name=>"MyApi", :options=>[{:key=>"Create", :value=>"/api/create"}, {:key=>"Update", :value=>"/api/update"}], :service_description=>{:service_id=>1, :services=>["Create", "Update"]}}
```

This setup is ideal to toss in Hashed versions of JSON data and instantiate your objects.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rodgco/simplify_api. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](https://www.contributor-covenant.org/) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

Ruby is Beautiful!!!