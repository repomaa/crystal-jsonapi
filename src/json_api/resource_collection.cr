module JSONApi
  class ResourceCollection(T)
    def initialize(@resources : (Iterable(T) | Enumerable(T)), @self_link = "#{API_ROOT}/#{T.type}")
    end

    private def serialize_data(io)
      io.json_array do |array|
        @resources.each do |resource|
          array << resource
        end
      end
    end

    private def serialize_links(io)
      io.json_object do |object|
        object.field(:self, @self_link)
      end
    end

    def to_json(io)
      io.json_object do |object|
        object.field(:links) { serialize_links(io) }
        object.field(:data) { serialize_data(io) }
      end
    end
  end
end
