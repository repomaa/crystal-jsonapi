module JSONApi
  abstract class Resource
    getter id

    def self.type=(type)
      @@type = type
    end

    def self.type
      @@type
    end

    def type
      self.class.type || "#{self.class.name.split("::").last.underscore}s"
    end

    def self_link
      "#{API_ROOT}/#{type}/#{id}"
    end

    def to_json(io)
      io.json_object do |object|
        object.field(:type, type)
        object.field(:id, id.to_s)
        serialize_attributes(object, io)
        serialize_links(object, io)
      end
    end

    private def serialize_attributes(object, io)
      return unless self.responds_to?(:attributes)
      object.field(:attributes) do
        io.json_object do |object|
          self.attributes(object, io)
        end
      end
    end

    private def serialize_links(object, io)
      object.field(:links) do
        io.json_object do |object|
          object.field(:self, self_link)
        end
      end
    end
  end
end
