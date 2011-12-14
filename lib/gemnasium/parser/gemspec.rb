module Gemnasium
  module Parser
    class Gemspec
      attr_reader :content

      def initialize(content)
        @content = content
      end

      def dependencies
        raise NotImplementedError
      end
    end
  end
end
