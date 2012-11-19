require "gemnasium/parser/configuration"
require "gemnasium/parser/gemfile"
require "gemnasium/parser/gemspec"

module Gemnasium
  module Parser
    extend Configuration

    def self.gemfile(content)
      # Remove CR chars "\r" from content since it breaks Patterns matching
      # TODO: Find something cleaner than this workaround
      Gemnasium::Parser::Gemfile.new(content.gsub("\r",''))
    end

    def self.gemspec(content)
      # Remove CR chars "\r" from content since it breaks Patterns matching
      # TODO: Find something cleaner than this workaround
      Gemnasium::Parser::Gemspec.new(content.gsub("\r",''))
    end
  end
end
