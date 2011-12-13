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
        @dependencies ||= [].tap do |deps|
          gem_matches.each do |match|
            name = match[:name]
            reqs = [match[:req1], match[:req2]].compact
            opts = Gemnasium::Parser::Patterns.options(match[:opts])
            deps << Bundler::Dependency.new(name, reqs, opts)
          end
        end
      end

      private
        def gem_matches
          @gem_matches ||= matches(Gemnasium::Parser::Patterns::GEM_CALL)
        end

        def gemspec_matches
          @gemspec_matches ||= matches(Gemnasium::Parser::Patterns::GEMSPEC_CALL)
        end

        def matches(pattern)
          [].tap{|m| content.scan(pattern){ m << Regexp.last_match } }
        end

        def bundler
          @bundler ||= Bundler::Dsl.new
        end
    end
  end
end
