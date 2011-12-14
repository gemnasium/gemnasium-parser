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
            dep = dependency(match)
            deps << dep if dep
          end
        end
      end

      def gemspec
        @gemspec = if gemspec_match
          opts = Patterns.options(gemspec_match["opts"])
          path = opts["path"]
          name = opts["name"] || "*"
          File.join(*[path, "#{name}.gemspec"].compact)
        end
      end

      def gemspec?
        !!gemspec
      end

      private
        def gem_matches
          @gem_matches ||= matches(Patterns::GEM_CALL)
        end

        def matches(pattern)
          [].tap{|m| content.scan(pattern){ m << Regexp.last_match } }
        end

        def dependency(match)
          opts = Patterns.options(match["opts"])
          return nil if exclude?(match, opts)
          clean!(match, opts)
          name, reqs = match["name"], [match["req1"], match["req2"]].compact
          Bundler::Dependency.new(name, reqs, opts).tap do |dep|
            line = content.slice(0, match.begin(0)).count("\n") + 1
            dep.instance_variable_set(:@line, line)
          end
        end

        def groups(match)
          group = group_matches.detect{|m| in_block?(match, m) }
          group && Patterns.values(group[:grps])
        end

        def in_block?(inner, outer)
          outer.begin(:blk) <= inner.begin(0) && outer.end(:blk) >= inner.end(0)
        end

        def group_matches
          @group_matches ||= matches(Patterns::GROUP_CALL)
        end

        def exclude?(match, opts)
          git?(match, opts) || path?(match, opts)
        end

        def git?(match, opts)
          opts["git"] || in_git_block?(match)
        end

        def in_git_block?(match)
          git_matches.any?{|m| in_block?(match, m) }
        end

        def git_matches
          @git_matches ||= matches(Patterns::GIT_CALL)
        end

        def path?(match, opts)
          opts["path"] || in_path_block?(match)
        end

        def in_path_block?(match)
          path_matches.any?{|m| in_block?(match, m) }
        end

        def path_matches
          @path_matches ||= matches(Patterns::PATH_CALL)
        end

        def clean!(match, opts)
          opts["group"] ||= groups(match)
          groups = Array(opts["group"]).flatten.compact
          runtime = groups.empty? || !(groups & Parser.runtime_groups).empty?
          opts["type"] ||= runtime ? :runtime : :development
        end

        def gemspec_match
          return @gemspec_match if defined?(@gemspec_match)
          @gemspec_match = content.match(Patterns::GEMSPEC_CALL)
        end
    end
  end
end
