# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ulysses/version'

Gem::Specification.new do |spec|
  spec.name          = "ulysses"
  spec.version       = Ulysses::VERSION
  spec.authors       = ["Yaodong Zhao"]
  spec.email         = ["y@whir.org"]

  spec.summary       = 'Access ulysses library by ruby'
  spec.description   = 'Access ulysses library by ruby'
  spec.homepage      = 'https://github.com/yaodong/gem-ulysses'
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'nokogiri'
  spec.add_dependency 'kramdown'
  spec.add_dependency 'htmlentities'

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"

end
