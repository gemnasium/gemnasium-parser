module Gemnasium
  module Parser
    class Gemspec
      attr_reader :content

      def initialize(content)
        @content = content
      end

      def dependencies
        @dependencies ||= [].tap do |deps|
          runtime_matches.each do |match|
            dep = dependency(match)
            deps << dep
          end
        end
      end

      private
        def runtime_matches
          @runtime_matches ||= matches(Patterns::RUNTIME_CALL)
        end

        def matches(pattern)
          [].tap{|m| content.scan(pattern){ m << Regexp.last_match } }
        end

        def dependency(match)
          name, reqs = match["name"], [match["req1"], match["req2"]].compact
          Bundler::Dependency.new(name, reqs).tap do |dep|
            line = content.slice(0, match.begin(0)).count("\n") + 1
            dep.instance_variable_set(:@line, line)
          end
        end
    end
  end
end
