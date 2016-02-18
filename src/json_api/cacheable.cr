module JSONApi
  module Cacheable
    class CacheIO < MemoryIO
      def initialize(@io)
        super()
      end

      def write(slice)
        super
        @io.write(slice)
      end
    end

    abstract def to_cached_json(io)
    abstract def cache_key

    macro cache_key(*args)
      def cache_key
        [{{args.argify}}].map(&.hash)
      end

      def_hash self.cache_key
    end

    macro included
      def to_json(io)
        cache = @@cache ||= {} of Int32 => String
        hash = self.hash
        cached_json = cache[hash]?
        if cached_json
          io << cached_json
        else
          cache[hash] = begin
            cache_io = CacheIO.new(io)
            to_cached_json(cache_io)
            cache_io.to_s
          end
        end
      end
    end
  end
end
