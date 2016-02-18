require "./cacheable"
module JSONApi
  abstract class Relationship
    include Cacheable

    def initialize(@resource_link, @name, @type)
    end

    protected abstract def serialize_data(io)


    def self_link
      "#{@resource_link}/relationships/#{@name}"
    end

    def related_link
      "#{@resource_link}/#{@name}"
    end

    def to_cached_json(io)
      io.json_object do |object|
        object.field(:links) { serialize_links(io) }
        object.field(:data) { serialize_data(io) }
      end
    end

    private def serialize_links(io)
      io.json_object do |object|
        object.field(:self, self_link)
        object.field(:related, related_link)
      end
    end
  end
end
