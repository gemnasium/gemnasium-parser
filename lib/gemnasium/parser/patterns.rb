module Gemnasium
  module Parser
    module Patterns
      GEM_NAME = /[a-zA-Z0-9\-_]+/

      MATCHER = /(?:=|!=|>|<|>=|<=|~>)/
      VERSION = /[0-9]+(?:\.[a-zA-Z0-9]+)*/
      REQUIREMENT = /\s*(?:#{MATCHER}\s*)?#{VERSION}\s*/
      REQUIREMENT_LIST = /(?<qr1>["'])(?<req1>#{REQUIREMENT})\k<qr1>(?:\s*,\s*(?<qr2>["'])(?<req2>#{REQUIREMENT})\k<qr2>)?/
      REQUIREMENTS = /(?:#{REQUIREMENT_LIST}|\[\s*#{REQUIREMENT_LIST}\s*\])/

      KEY = /(?::\w+|:?"\w+"|:?'\w+')/
      SYMBOL = /(?::\w+|:"[^"#]+"|:'[^']+')/
      STRING = /(?:"[^"#]*"|'[^']*')/
      BOOLEAN = /(?:true|false)/
      NIL = /nil/
      ELEMENT = /(?:#{SYMBOL}|#{STRING})/
      ARRAY = /\[(?:#{ELEMENT}(?:\s*,\s*#{ELEMENT})*)?\]/
      VALUE = /(?:#{BOOLEAN}|#{NIL}|#{ELEMENT}|#{ARRAY}|)/
      PAIR = /(?:(#{KEY})\s*=>\s*(#{VALUE})|(\w+):\s+(#{VALUE}))/
      OPTIONS = /#{PAIR}(?:\s*,\s*#{PAIR})*/

      GEM_CALL = /^\s*gem\s+(?<q1>["'])(?<name>#{GEM_NAME})\k<q1>(?:\s*,\s*#{REQUIREMENT_LIST})?(?:\s*,\s*(?<opts>#{OPTIONS}))?\s*$/

      SYMBOLS = /#{SYMBOL}(\s*,\s*#{SYMBOL})*/
      GROUP_CALL = /^(?<i1>\s*)group\s+(?<grps>#{SYMBOLS})\s+do\s*?\n(?<blk>.*?)\n^\k<i1>end\s*$/m

      GIT_CALL = /^(?<i1>\s*)git\s+.*?\n(?<blk>.*?)\n^\k<i1>end\s*$/m

      PATH_CALL = /^(?<i1>\s*)path\s+.*?\n(?<blk>.*?)\n^\k<i1>end\s*$/m

      GEMSPEC_CALL = /^\s*gemspec(?:\s+(?<opts>#{OPTIONS}))?\s*$/

      RUNTIME_CALL = /^\s*\w+\.add(?<type>_runtime|_development)?_dependency\s+(?<q1>["'])(?<name>#{GEM_NAME})\k<q1>(?:\s*,\s*#{REQUIREMENTS})?\s*$/

      def self.options(string)
        {}.tap do |hash|
          return hash unless string
          pairs = Hash[*string.match(OPTIONS).captures.compact]
          pairs.each{|k,v| hash[key(k)] = value(v) }
        end
      end

      def self.key(string)
        string.tr(%(:"'), "")
      end

      def self.value(string)
        case string
        when ARRAY then values(string.tr("[]", ""))
        when SYMBOL then string.tr(%(:"'), "").to_sym
        when STRING then string.tr(%("'), "")
        when BOOLEAN then string == "true"
        when NIL then nil
        end
      end

      def self.values(string)
        string.strip.split(/\s*,\s*/).map{|v| value(v) }
      end
    end
  end
end
