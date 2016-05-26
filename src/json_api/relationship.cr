require "./cacheable"
module JSONApi
  abstract class Relationship
    include Cacheable

    @name : (Symbol | String)
    @type : (Symbol | String)
    @resource_link : String?
    @self_link : String?
    @related_link : String?

    getter name, type
    def initialize(@name, @type, @resource_link = nil)
      @resource_link.try do |resource_link|
        @self_link = "#{resource_link}/relationships/#{@name}"
        @related_link = "#{resource_link}/#{@name}"
      end
    end

    protected abstract def serialize_data(object, io)

    def to_cached_json(io)
      io.json_object do |object|
        object.field(:links) { serialize_links(io) }
        serialize_data(object, io)
      end
    end

    private def serialize_links(io)
      io.json_object do |object|
        object.field(:self, @self_link)
        object.field(:related, @related_link)
      end
    end
  end
end
