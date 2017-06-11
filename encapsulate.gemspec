# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'encapsulate/version'

Gem::Specification.new do |spec|
  spec.name          = "encapsulate"
  spec.version       = Encapsulate::VERSION
  spec.authors       = ["thisismydesign"]
  spec.email         = ["thisismydesign@users.noreply.github.com"]

  spec.summary       = "A small framework that enables encapsulating pieces of code within eachother."
  spec.homepage      = "https://github.com/thisismydesign/encapsulate"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "reflection_utils"

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "coveralls"
end
