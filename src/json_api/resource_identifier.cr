module JSONApi
  class ResourceIdentifier
    def initialize(@type, @id)
    end

    def to_json(io)
      io.json_object do |object|
        object.field(:type, @type)
        object.field(:id, @id.to_s)
      end
    end
  end
end
