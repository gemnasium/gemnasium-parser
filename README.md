# Gemnasium::Parser

[![Gem Version](https://img.shields.io/gem/v/formatador.svg)]()
[![Build Status](https://img.shields.io/travis/gemnasium/gemnasium-parser/master.svg)](https://travis-ci.org/gemnasium/gemnasium-parser)
[![Dependency Status](https://img.shields.io/gemnasium/gemnasium/gemnasium-parser.svg)](https://gemnasium.com/gemnasium/gemnasium-parser)

The [Gemnasium](https://gemnasium.com/) parser determines gem dependencies from gemfiles and gemspecs, without evaluating the Ruby.

## Why?

[Bundler](http://gembundler.com/) is wonderful. It takes your gemfile and your gemspec (both just Ruby) and evaluates them, determining your gem dependencies. This works great locally and even on your production server… but only because you can be trusted!

An untrustworthy character could put some pretty nasty stuff in a gemfile. If Gemnasium were to blindly evaluate that Ruby on its servers, havoc would ensue.

### Solution #1

If evaluating Ruby is so dangerous, just sandbox it! [Travis CI](http://travis-ci.org/) runs its builds inside isolated environments built with [Vagrant](http://vagrantup.com/). That way, if anything goes awry, it’s in a controlled environment.

This is entirely possible with Gemnasium, but it’s impractical. Gemfiles often `require` other files in the repository. So to evaluate a gemfile, Gemnasium needs to clone the entire repo. That’s an expensive operation when only a couple files determine the dependencies.

### Solution #2

Parse Ruby like Ruby parses Ruby.

Ruby 1.9 includes a library called Ripper. Ripper is a Ruby parsing library that can break down a gemfile or gemspec into bite-sized chunks, without evaluating the source. Then it can be searched for just the methods that matter.

The problem is that it’s hard to make heads or tails from Ripper’s output, at least for me. I could see the Gemnasium parser one day moving to this strategy. But not today.

### Third try’s the charm

If we can’t evaluate the Ruby and Ripper’s output is unmanageable, how else can we find patterns in a gemfile or gemspec and get usable output?

Regular expressions!

The Gemnasium parser, for both gemfiles and gemspecs, is based on a number of Ruby regular expressions. These patterns match `gem` method calls in gemfiles and `add_dependency` calls in gemspecs.

For a more comprehensive list of its abilities, see the [specs](https://github.com/laserlemon/gemnasium-parser/tree/master/spec).

## Contributing <a name="contributing"></a>

1. Fork it
2. Create your branch (`git checkout -b my-bugfix`)
3. Commit your changes (`git commit -am "Fix my bug"`)
4. Push your branch (`git push origin my-bugfix`)
5. Send a pull request

## Problems?

If you have a gemfile or gemspec that the Gemnasium parser screws up…

1. Boil it down to its simplest problematic form
2. Write a failing spec
3. See [Contributing](#contributing)
