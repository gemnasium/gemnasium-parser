require "gemnasium/parser/configuration"
require "gemnasium/parser/gemfile"
require "gemnasium/parser/gemspec"

module Gemnasium
  module Parser
    extend Configuration

    def self.gemfile(content)
    end

    def self.gemspec(content)
    end
  end
end
