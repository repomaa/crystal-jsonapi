require "./resource"
require "./success_response"

module JSONApi
  class ResourceCollectionResponse(T) < SuccessResponse
    def initialize(
      @resources : (Enumerable(T) | Iterator(T)),
      @self_link = T.type : String,
      @included = nil : (Enumerable(Resource) | Iterator(Resource))?
    )
      {% unless JSONApi::Resource.all_subclasses.includes?(T) %}
        {% raise "resources must be an Enumerable of Resource, not #{T}" %}
      {% end %}
    end

    protected def serialize_data(object, io)
      object.field(:data) do
        io.json_array do |array|
          @resources.each do |resource|
            array << resource
          end
        end
      end
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
