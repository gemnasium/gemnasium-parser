# encoding: utf-8

Gem::Specification.new do |gem|
  gem.name    = "gemnasium-parser"
  gem.version = "0.1.9"

  gem.authors     = "Steve Richert"
  gem.email       = "steve.richert@gmail.com"
  gem.description = "Safely parse Gemfiles and gemspecs"
  gem.summary     = gem.description
  gem.homepage    = "https://github.com/gemnasium/gemnasium-parser"

  gem.add_development_dependency "rake", ">= 0.8.7"
  gem.add_development_dependency "rspec", "~> 2.4"

  gem.files         = `git ls-files`.split($\)
  gem.test_files    = gem.files.grep(/^spec\//)
  gem.require_paths = ["lib"]
end
