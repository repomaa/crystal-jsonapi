require "./cacheable"

module JSONApi
  class ResourceIdentifier
    include Cacheable
    cache_key @type, @id

    def initialize(@type, @id)
    end

    def to_cached_json(io)
      io.json_object do |object|
        object.field(:type, @type)
        object.field(:id, @id.to_s)
      end
    end
  end
end
