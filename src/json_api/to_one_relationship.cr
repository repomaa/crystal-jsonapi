require "./relationship"
require "./resource_identifier"
require "./cacheable"
require "./types"

module JSONApi
  class ToOneRelationship < Relationship
    @resource_identifier : ResourceIdentifier?

    def initialize(name, type, @id : ID? = :none, resource_link = nil)
      super(name, type, resource_link)
      if (id = @id) && (id != :none)
        @resource_identifier = ResourceIdentifier.new(type, id)
      end
    end

    protected def serialize_data(object, io)
      return if @id == :none
      object.field(:data, @resource_identifier)
    end
  end
end
