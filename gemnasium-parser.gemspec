# -*- encoding: utf-8 -*-

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
  gem.version       = "0.1.4"

  gem.add_development_dependency "rake", ">= 0.8.7"
  gem.add_development_dependency "rspec", "~> 2.4"
end
