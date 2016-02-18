require "./relationship"
require "./resource_identifier"
require "./cacheable"

module JSONApi
  class ToOneRelationship < Relationship
    cache_key @resource_link, @name, @type, @id

    def initialize(resource_link, name, type, @id)
      super(resource_link, name, type)
      @resource_identifier = @id.try { |id| ResourceIdentifier.new(type, id) }
    end

    protected def serialize_data(io)
      @resource_identifier.to_json(io)
    end
  end
end
