require "./success_response"

module JSONApi
  class ResourceResponse < SuccessResponse
    def initialize(
      @resource : Resource?,
      self_link = nil : String?,
      @included = nil : (Enumerable(Resource) | Iterator(Resource))?
    )
      super(200)
      @self_link = self_link || "#{API_ROOT}/#{@resource.type}/#{@resource.id}"
    end

    protected def serialize_data(object, io)
      object.field(:data, @resource)
    end

    protected def serialize_links(object, io)
      object.field(:links) do
        io.json_object do |object|
          object.field(:self, @self_link)
        end
      end
    end
  end
end
