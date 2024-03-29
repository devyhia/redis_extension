# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'redis_extension/version'

Gem::Specification.new do |spec|
  spec.name          = "redis_extension"
  spec.version       = RedisExtension::VERSION
  spec.authors       = ["Yehia Abo El-Nga"]
  spec.email         = ["yehia@devrok.com"]
  spec.description   = %q{Adds Redis Caching Middleware to ActiveRecord models}
  spec.summary       = %q{Adds Redis Caching Middleware to ActiveRecord models}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
