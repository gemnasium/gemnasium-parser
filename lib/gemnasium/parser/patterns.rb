module Gemnasium
  module Parser
    module Patterns
      GEM_NAME = /[a-zA-Z0-9\-_]+/

      MATCHER = /(?:=|!=|>|<|>=|<=|~>)/
      VERSION = /[0-9]+(?:\.[a-zA-Z0-9]+)*/
      REQUIREMENT = /\s*(?:#{MATCHER}\s*)?#{VERSION}\s*/

      KEY = /(?::\w+|:?"\w+"|:?'\w+')/
      SYMBOL = /(?::\w+|:"[^"]+"|'[^']+')/
      STRING = /(?:"[^"]*"|'[^']*')/
      BOOLEAN = /(?:true|false)/
      NIL = /nil/
      ELEMENT = /(?:#{SYMBOL}|#{STRING})/
      ARRAY = /\[(?:#{ELEMENT}(?:\s*,\s*#{ELEMENT})*)?\]/
      VALUE = /(?:#{BOOLEAN}|#{NIL}|#{ELEMENT}|#{ARRAY}|)/
      PAIR = /(?:#{KEY}\s*=>\s*#{VALUE}|\w+:\s+#{VALUE})/
      OPTIONS = /#{PAIR}(?:\s*,\s*#{PAIR})*/

      GEM_CALL = /^\s*gem\s+(?<q1>["'])(?<name>#{GEM_NAME})\k<q1>(?:\s*,\s*(?<q2>["'])(?<requirement_1>#{REQUIREMENT})\k<q2>(?:\s*,\s*(?<q3>["'])(?<requirement_2>#{REQUIREMENT})\k<q3>)?)?(?:\s*,\s*(?<options>#{OPTIONS})\s*)?$/
    end
  end
end
