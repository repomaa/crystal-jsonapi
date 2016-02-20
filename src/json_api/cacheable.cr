require "./cache"

module JSONApi
  module Cacheable
    abstract def to_cached_json(io)
    abstract def cache_key

    macro cache_key(*args)
      def cache_key
        [self.class.name, {{args.argify}}].map(&.hash)
      end

      def_hash self.cache_key
    end

    def to_json(io)
      cache = JSONApi::Cache.instance
      cache.fetch(self.hash, io) do |cache_record|
        to_cached_json(cache_record)
      end
    end
  end
end
