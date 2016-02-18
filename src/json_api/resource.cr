require "./cacheable"

module JSONApi
  abstract class Resource
    include Cacheable

    getter id

    def self.type
      @@type || "#{name.split("::").last.underscore}s"
    end

    def type
      self.class.type
    end

    def self_link
      "#{API_ROOT}/#{type}/#{id}"
    end

    def to_cached_json(io)
      io.json_object do |object|
        object.field(:type, type)
        object.field(:id, id.to_s)
        serialize_attributes(object, io)
        serialize_relationships(object, io)
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

    private def serialize_relationships(object, io)
      return unless self.responds_to?(:relationships)
      object.field(:relationships) do
        io.json_object do |object|
          self.relationships(object, io)
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
