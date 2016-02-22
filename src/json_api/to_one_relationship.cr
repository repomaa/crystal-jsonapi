require "./relationship"
require "./resource_identifier"
require "./cacheable"

module JSONApi
  class ToOneRelationship < Relationship
    def initialize(name, type, @id, resource_link = nil)
      super(name, type, resource_link)
      @resource_identifier = @id.try { |id| ResourceIdentifier.new(type, id) }
    end

    protected def serialize_data(io)
      @resource_identifier.to_json(io)
    end
  end
end
