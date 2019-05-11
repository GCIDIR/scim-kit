# frozen_string_literal: true

require 'parslet'

module Scim
  module Kit
    module V2
      # Parses SCIM filter queries
      class Parser < Parslet::Parser
        root :filter

        # FILTER = attrExp / logExp / valuePath / *1"not" "(" FILTER ")"
        rule(:filter) do
          (attribute_expression | logical_expression | value_path) |
            (not_op >> lparen >> filter >> rparen)
        end

        # valuePath = attrPath "[" valFilter "]" ; FILTER uses sub-attributes of a parent attrPath
        rule(:value_path) do
          attribute_path >> lbracket >> value_filter >> rbracket
        end

        # valFilter = attrExp / logExp / *1"not" "(" valFilter ")"
        rule(:value_filter) do
          attribute_expression |
            logical_expression |
            (not_op >> lparen >> value_filter >> rparen)
        end

        # attrExp = (attrPath SP "pr") / (attrPath SP compareOp SP compValue)
        rule(:attribute_expression) do
          (attribute_path >> space >> presence) |
            (attribute_path >> space >> comparison_operator >> space >> quote >> comparison_value >> quote)
        end

        # logExp = FILTER SP ("and" / "or") SP FILTER
        rule(:logical_expression) do
          filter >> space >> (and_op | or_op) >> space >> filter
        end

        # compValue = false / null / true / number / string ; rules from JSON (RFC 7159)
        rule(:comparison_value) do
          (falsey | null | truthy | number | string).repeat(1)
        end

        # compareOp = "eq" / "ne" / "co" / "sw" / "ew" / "gt" / "lt" / "ge" / "le"
        rule(:comparison_operator) do
          equal | not_equal | contains | starts_with | ends_with |
            greater_than | less_than | less_than_equals | greater_than_equals
        end

        # attrPath = [URI ":"] ATTRNAME *1subAttr ; SCIM attribute name ; URI is SCIM "schema" URI
        rule(:attribute_path) do
          (scim_schema_uri >> colon).repeat(0, 1) >> attribute_name >> sub_attribute.maybe
        end

        # ATTRNAME  = ALPHA *(nameChar)
        rule(:attribute_name) { alpha >> name_character.repeat(0, nil) }

        # nameChar = "-" / "_" / DIGIT / ALPHA
        rule(:name_character) { hyphen | underscore | digit | alpha }

        # subAttr = "." ATTRNAME ; a sub-attribute of a complex attribute
        rule(:sub_attribute) { dot >> attribute_name }

        rule(:presence) { str('pr') }
        rule(:and_op) { str('and') }
        rule(:or_op) { str('or') }
        rule(:not_op) { str('not').repeat(0, 1) }
        rule(:falsey) { str('false') }
        rule(:truthy) { str('true') }
        rule(:null) { str('null') }
        rule(:number) { digit.repeat(1) }
        rule(:scim_schema_uri) { (alpha | digit | dot | colon).repeat(1) }
        rule(:equal) { str('eq') }
        rule(:not_equal) { str('ne') }
        rule(:contains) { str('co') }
        rule(:starts_with) { str('sw') }
        rule(:ends_with) { str('ew') }
        rule(:greater_than) { str('gt') }
        rule(:less_than) { str('lt') }
        rule(:greater_than_equals) { str('ge') }
        rule(:less_than_equals) { str('le') }
        rule(:string) { (alpha | single_quote | at | dot | hyphen | colon | digit).repeat(1) }
        rule(:lparen) { str('(') }
        rule(:rparen) { str(')') }
        rule(:lbracket) { str('[') >> space? }
        rule(:rbracket) { str(']') >> space? }
        rule(:digit) { match('\d') }
        rule(:at) { str('@') }
        rule(:quote) { str('"') }
        rule(:single_quote) { str("'") }
        rule(:space) { match('\s') }
        rule(:space?) { space.maybe }
        rule(:alpha) { match['a-zA-Z'] }
        rule(:dot) { str('.') }
        rule(:colon) { str(':') }
        rule(:hyphen) { str('-') }
        rule(:underscore) { str('_') }
      end
    end
  end
end
