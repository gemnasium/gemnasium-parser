module Gemnasium
  module Parser
    module Patterns
      GEM_NAME = /[a-zA-Z0-9\-_]+/
      MATCHER = /(?:=|!=|>|<|>=|<=|~>)/
      VERSION = /[0-9]+(?:\.[a-zA-Z0-9]+)*/
      REQUIREMENT = /\s*(?:#{MATCHER}\s*)?#{VERSION}\s*/

      GEM_CALL = /^\s*gem\s+(?<q1>["'])(?<name>#{GEM_NAME})\k<q1>(?:\s*,\s*(?<q2>["'])(?<requirement_1>#{REQUIREMENT})\k<q2>(?:\s*,\s*(?<q3>["'])(?<requirement_2>#{REQUIREMENT})\k<q3>)?)?/
    end
  end
end
