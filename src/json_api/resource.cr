require "./cacheable"

module JSONApi
  abstract class Resource
    include Cacheable

    macro relationships(map)
      {% for key, value in map %}
        {% map[key] = { to: value } unless value.is_a?(HashLiteral) %}
      {% end %}

      {% for key, value in map %}
        def {{key.id}}
          {% type = "JSONApi::To#{value[:to].id.camelcase}Relationship".id %}
          @{{key.id}} ||= {{type}}.new(
            {{key.id.stringify}},
            {% if value[:type] %}
              {{value[:type].id.stringify}},
            {% else %}
              "{{key.id}}{{(value[:to].id.stringify == "one" ? "s" : "").id}}",
            {% end %}
            {% if value[:key] %}
              {{value[:key].id}},
            {% elsif value[:keys] %}
              {{value[:keys].id}},
            {% end %}
            resource_link: self_link
          )
        end
      {% end %}

      def relationships(object, io)
        {% for key, value in map %}
          object.field({{key}}, {{key.id}})
        {% end %}
      end

      def relationships
        @relationships ||= {
          {% for key, value in map %}
            {{key.id}}: {{key.id}},
          {% end %}
        }
      end
    end

    macro attributes(map)
      {% for key, value in map %}
        {% map[key] = { type: value } unless value.is_a?(HashLiteral) %}
      {% end %}

      {% for key, value in map %}
        def {{key.id}} : {{value[:type]}}{{(value[:nilable] == true ? "?" : "").id}}
          @{{key.id}}
        end
      {% end %}

      def attributes(object, io)
        {% for key, value in map %}
          object.field({{key}}) { {{key.id}}.to_json(io) }
        {% end %}
      end

      def attributes
        @attributes ||= {
          {% for key, value in map %}
            {{key.id}}: {{key.id}},
          {% end %}
        }
      end
    end

    getter id

    def self.type
      @@type ||= "#{name.split("::").last.underscore}s"
    end

    def type
      self.class.type
    end

    def self_link
      "#{API_ROOT}/#{type}/#{id}"
    end

    def to_cached_json(io)
      io.json_object do |object|
        object.field(:type, type)
        object.field(:id, id.to_s)
        serialize_attributes(object, io)
        serialize_relationships(object, io)
        serialize_links(object, io)
      end
    end

    private def serialize_attributes(object, io)
      return unless self.responds_to?(:attributes)
      object.field(:attributes) do
        io.json_object do |object|
          self.attributes(object, io)
        end
      end
    end

    private def serialize_relationships(object, io)
      return unless self.responds_to?(:relationships)
      object.field(:relationships) do
        io.json_object do |object|
          self.relationships(object, io)
        end
      end
    end

    private def serialize_links(object, io)
      object.field(:links) do
        io.json_object do |object|
          object.field(:self, self_link)
        end
      end
    end
  end
end
