require "./cache"

module JSONApi
  module Cacheable
    abstract def to_cached_json(io)

    macro def cache_key : Int32
      [
        {{@type.name.stringify}},
        {{@type.instance_vars.map { |var| "@#{var}".id }.argify}}
      ].hash
    end

    def to_json(io)
      cache = JSONApi::Cache.instance
      cache.fetch(cache_key, io) do |cache_record|
        to_cached_json(cache_record)
      end
    end
  end
end
