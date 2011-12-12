# -*- encoding: utf-8 -*-
require File.expand_path('../lib/gemnasium/parser/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = "Steve Richert"
  gem.email         = "steve.richert@gmail.com"
  gem.description   = "Safely parse Gemfiles and gemspecs"
  gem.summary       = "Safely parse Gemfiles and gemspecs"
  gem.homepage      = "https://github.com/laserlemon/gemnasium-parser"

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "gemnasium-parser"
  gem.require_paths = ["lib"]
  gem.version       = Gemnasium::Parser::VERSION
end
