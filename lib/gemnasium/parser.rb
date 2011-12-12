require "gemnasium/parser/configuration"
require "gemnasium/parser/gemfile"
require "gemnasium/parser/gemspec"

module Gemnasium
  module Parser
    extend Configuration

    def self.gemfile(content)
      Gemnasium::Parser::Gemfile.new(content)
    end

    def self.gemspec(content)
      Gemnasium::Parser::Gemspec.new(content)
    end
  end
end
