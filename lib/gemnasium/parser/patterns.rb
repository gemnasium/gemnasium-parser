module Gemnasium
  module Parser
    module Patterns
      GEM_NAME = /[a-zA-Z0-9\-_]+/

      MATCHER = /(?:=|!=|>|<|>=|<=|~>)/
      VERSION = /[0-9]+(?:\.[a-zA-Z0-9]+)*/
      REQUIREMENT = /\s*(?:#{MATCHER}\s*)?#{VERSION}\s*/

      KEY = /(?::\w+|:?"\w+"|:?'\w+')/
      SYMBOL = /(?::\w+|:"[^"#]+"|'[^']+')/
      STRING = /(?:"[^"#]*"|'[^']*')/
      BOOLEAN = /(?:true|false)/
      NIL = /nil/
      ELEMENT = /(?:#{SYMBOL}|#{STRING})/
      ARRAY = /\[(?:#{ELEMENT}(?:\s*,\s*#{ELEMENT})*)?\]/
      VALUE = /(?:#{BOOLEAN}|#{NIL}|#{ELEMENT}|#{ARRAY}|)/
      PAIR = /(?:(#{KEY})\s*=>\s*(#{VALUE})|(\w+):\s+(#{VALUE}))/
      OPTIONS = /#{PAIR}(?:\s*,\s*#{PAIR})*/

      GEM_CALL = /^\s*gem\s+(?<q1>["'])(?<name>#{GEM_NAME})\k<q1>(?:\s*,\s*(?<q2>["'])(?<req1>#{REQUIREMENT})\k<q2>(?:\s*,\s*(?<q3>["'])(?<req2>#{REQUIREMENT})\k<q3>)?)?(?:\s*,\s*(?<opts>#{OPTIONS}))?\s*$/

      GEMSPEC_CALL = /^\s*gemspec(?:\s+(?<opts>#{OPTIONS}))?\s*$/

      def self.options(string)
        return {} unless string
        hash, raw = {}, Hash[*string.match(OPTIONS).captures.compact]
        raw.each do |key, value|
          new_key = key.tr(%(:"'), "").to_sym
          new_value = case value
          when BOOLEAN then value == "true"
          when NIL then nil
          when SYMBOL then value.tr(%(:"'), "").to_sym
          when STRING then value.tr(%("'), "")
          end
          hash[new_key] = new_value
        end
        hash
      end
    end
  end
end
