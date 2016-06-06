# encoding: utf-8

Gem::Specification.new do |gem|
  gem.name    = "gemnasium-parser"
  gem.version = "0.2.0"

  gem.authors     = "Steve Richert"
  gem.email       = "steve.richert@gmail.com"
  gem.description = "Safely parse Gemfiles and gemspecs"
  gem.summary     = gem.description
  gem.homepage    = "https://github.com/gemnasium/gemnasium-parser"

  gem.add_development_dependency "bundler", "~> 1.0"

  gem.files         = `git ls-files`.split($\)
  gem.test_files    = gem.files.grep(/^spec\//)
  gem.require_paths = ["lib"]
end
