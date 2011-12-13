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
        @dependencies ||= gem_matches.map do |match|
          name = match[:name]
          reqs = [match[:req1], match[:req2]].compact
          opts = Gemnasium::Parser::Patterns.options(match[:opts])
          Bundler::Dependency.new(name, reqs, opts)
        end
      end

      def gemspec
        @gemspec = if gemspec_match
          opts = Gemnasium::Parser::Patterns.options(gemspec_match[:opts])
          path = opts[:path]
          name = opts[:name] || "*"
          File.join(*[path, "#{name}.gemspec"].compact)
        end
      end

      def gemspec?
        !!gemspec
      end

      private
        def gem_matches
          @gem_matches ||= [].tap do |matches|
            content.scan(Patterns::GEM_CALL) do
              matches << Regexp.last_match
            end
          end
        end

        def gemspec_match
          return @gemspec_match if defined?(@gemspec_match)
          @gemspec_match = content.match(Patterns::GEMSPEC_CALL)
        end

        def bundler
          @bundler ||= Bundler::Dsl.new
        end
    end
  end
end
