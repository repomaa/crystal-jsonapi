module JSONApi
  abstract class Relationship(T)
    def initialize(@resource : T, @repository, @name, @type)
    end

    protected abstract def serialize_data(io)

    def self_link
      "#{@resource.self_link}/relationships/#{@name}"
    end

    def related_link
      "#{@resource.self_link}/#{@name}"
    end

    def to_json(io)
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
