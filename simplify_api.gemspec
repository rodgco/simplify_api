# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'simplify_api/version'

Gem::Specification.new do |spec|
  spec.name = 'simplify_api'
  spec.version = SimplifyApi::VERSION
  spec.date = '2019-05-07'
  spec.authors = ['Rodrigo Garcia Couto']
  spec.email = ['r@rodg.co']
  spec.summary = 'A simple set of tools to help the use of APIs'
  spec.description = 'A simple set of tools to simplify the use of APIs in Ruby'
  spec.homepage = 'https://github.com/rodgco/simplify_api'
  spec.license = 'MIT'
  spec.files = `git ls-files -z`.split("\x0")
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rspec', '~> 3.8'
  spec.add_development_dependency 'rspec-collection_matchers', '~> 1.1'
  spec.add_development_dependency 'rubocop', '>= 0.49.0'
  spec.add_development_dependency 'rubocop-performance', '~> 1.4'
end
