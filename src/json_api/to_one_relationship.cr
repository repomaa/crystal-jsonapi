require "./relationship"
require "./resource_identifier"

module JSONApi
  class ToOneRelationship(T) < Relationship(T)
    protected def serialize_data(io)
      @repository.related_id(@resource, @name).try { |id|
        ResourceIdentifier.new(@type, id)
      }.to_json(io)
    end
  end
end
