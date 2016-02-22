require "./has_meta"

module JSONApi
  abstract class Response
    include HasMeta
    JSON_API = { version: "1.0" }

    getter status_code
    def initialize(@status_code)
    end

    protected abstract def serialize_data(object, io)
    protected abstract def serialize_errors(object, io)
    protected abstract def serialize_links(object, io)
    protected abstract def serialize_included(object, io)

    def to_json(io)
      io.json_object do |object|
        object.field(:jsonapi, JSON_API)
        serialize_data(object, io)
        serialize_errors(object, io)
        serialize_meta(object, io)
        serialize_links(object, io)
        serialize_included(object, io)
      end
    end
  end
end
