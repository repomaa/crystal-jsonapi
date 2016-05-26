require "./cacheable"

module JSONApi
  class ResourceIdentifier
    include Cacheable

    def initialize(@type : (String | Symbol), @id : (String | Symbol | Int32))
    end

    def to_cached_json(io)
      io.json_object do |object|
        object.field(:type, @type)
        object.field(:id, @id.to_s)
      end
    end
  end
end
