require "./meta"

module JSONApi
  module HasMeta
    @meta : Meta?

    private def meta
      @meta
    end

    protected def serialize_meta(object, io)
      meta.try { |meta| object.field(:meta, meta) }
    end
  end
end
