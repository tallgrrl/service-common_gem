# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'service/common_gem/version'

Gem::Specification.new do |spec|
  spec.name          = "service-common_gem"
  spec.version       = Service::CommonGem::VERSION
  spec.authors       = ["wkbang"]
  spec.email         = ["wkbang@gmail.com"]
  spec.summary       = %q{Group of common methods.}
  spec.description   = %q{Methods for authentication/authorization are grouped in this gem.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "jruby-memcached"
end