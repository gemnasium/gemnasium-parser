require "bundler"
require "gemnasium/parser/patterns"

module Gemnasium
  module Parser
    class Gemfile
      attr_reader :content

      def initialize(content)
        @content = content
      end

      def dependencies
        [].tap do |dependencies|
          content.scan(Gemnasium::Parser::Patterns::GEM_CALL) do
            match = Regexp.last_match
            requirements = [match[:requirement_1], match[:requirement_2]].compact
            dependencies << Bundler::Dependency.new(match[:name], requirements)
          end
        end
      end
    end
  end
end
