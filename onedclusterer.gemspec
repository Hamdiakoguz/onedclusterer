# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'onedclusterer/version'

Gem::Specification.new do |spec|
  spec.name          = "onedclusterer"
  spec.version       = OnedClusterer::VERSION
  spec.authors       = ["Hamdi Akoguz"]
  spec.email         = ["hamdiakoguz@gmail.com"]

  spec.summary       = %q{a tiny ruby library for one-dimensional clustering methods.}
  spec.homepage      = "https://github.com/Hamdiakoguz/onedclusterer"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "pry"
end
