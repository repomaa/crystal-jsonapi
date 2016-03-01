require "./cacheable"
require "./has_meta"
require "./error_source"

module JSONApi
  class Error < Exception
    include Cacheable
    include HasMeta

    def initialize(@code : String, @title : String, @detail = nil : String?, @source = nil : ErrorSource?)
      super(@title, @detail)
    end

    def to_cached_json(io)
      io.json_object do |object|
        object.field(:code, @code)
        object.field(:title, @title)
        @detail.try { |detail| object.field(:detail, detail) }
        @source.try { |source| object.field(:source, source) }
        serialize_meta(object, io)
      end
    end
  end
end
