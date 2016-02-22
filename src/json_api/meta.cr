require "./cacheable"

module JSONApi
  abstract class Meta
    include Cacheable

    macro def to_cached_json(io) : Nil
      io.json_object do |object|
        {% for var in @type.instance_vars %}
          object.field(:{{var}}, @{{var}})
        {% end %}
      end
      nil
    end
  end
end
