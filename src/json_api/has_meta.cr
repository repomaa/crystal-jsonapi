require "./meta"

module JSONApi
  module HasMeta
    private def meta : Meta+?
      @meta
    end

    protected def serialize_meta(object, io)
      meta.try { |meta| object.field(:meta, meta) }
    end
  end
end
