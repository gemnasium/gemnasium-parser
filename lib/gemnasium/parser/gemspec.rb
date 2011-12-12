module Gemnasium
  module Parser
    class Gemspec
      def dependencies
        raise NotImplementedError
      end
    end
  end
end
