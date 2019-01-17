# frozen_string_literal: true

module Scim
  module Kit
    module V2
      # Represents a SCIM Schema
      class Schema
        include Templatable

        attr_reader :id, :name, :attributes, :meta
        attr_accessor :description

        def initialize(id:, name:, location:)
          @id = id
          @name = name
          @description = name
          @meta = Meta.new('Schema', location)
          @meta.created = @meta.last_modified = @meta.version = nil
          @attributes = []
          yield self if block_given?
        end

        def add_attribute(name:, type: :string)
          attribute = AttributeType.new(name: name, type: type)
          yield attribute if block_given?
          attributes << attribute
        end

        def core?
          id.include?(Schemas::CORE) || id.include?(Messages::CORE)
        end

        def self.build(*args)
          item = new(*args)
          yield item
          item
        end
      end
    end
  end
end
