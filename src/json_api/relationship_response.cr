require "./success_response"

module JSONApi
  class RelationshipResponse < SuccessResponse
    def initialize(resource_link, @relationship : Relationship)
      @self_link = "#{resource_link}/relationships/#{@relationship.name}"
      @related_link = "#{resource_link}/#{@relationship.name}"
    end

    protected def serialize_data(object, io)
      object.field(:data) do
        @relationship.serialize_data(io)
      end
    end

    protected def serialize_links(object, io)
      object.field(:links) do
        io.json_object do |object|
          object.field(:self, @self_link)
          object.field(:related, @related_link)
        end
      end
    end
  end
end
