# -*- encoding: utf-8 -*-
require File.expand_path('../lib/equivalence/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Ernie Miller"]
  gem.email         = ["ernie@erniemiller.org"]
  gem.description   = %q{Implement object equality by extending a module and calling a macro. Now you have no excuse for not doing it.}
  gem.summary       = %q{Because implementing object equality wasn't easy enough already.}
  gem.homepage      = "http://github.com/ernie/equivalence"

  gem.add_development_dependency 'rspec', '~> 2.11.0'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "equivalence"
  gem.require_paths = ["lib"]
  gem.version       = Equivalence::VERSION
end
