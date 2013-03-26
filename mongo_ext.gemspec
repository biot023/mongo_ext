# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'b23/mongo_ext/version'

Gem::Specification.new do |spec|
  spec.name          = "mongo_ext"
  spec.version       = B23::MongoExt::VERSION
  spec.authors       = ["Doug Livesey"]
  spec.email         = ["biot023@gmail.com"]
  spec.description   = %q{Some extensions to make using mongo collections a bit easier}
  spec.summary       = %q{Mongo extensions}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "mongo"
  spec.add_dependency "bson_ext"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
