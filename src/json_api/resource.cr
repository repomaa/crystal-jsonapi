require "./cacheable"
require "./unexpected_type_error"

module JSONApi
  abstract class Resource
    include Cacheable

    def get_attributes
    end

    def get_relationships
    end

    def update_attributes(pull)
    end

    def update_relationships(pull)
    end

    macro relationships(map)
      {% for key, value in map %}
        {% map[key] = { to: value } unless value.is_a?(HashLiteral) %}
        {% unless map[key][:type] %}
          {% map[key][:type] = "#{key.id}#{(value[:to].id.stringify == "one" ? "s" : "").id}" %}
        {% end %}
        {% unless map[key][:key] %}
          {% map[key][:key] = map[key][:keys] %}
        {% end %}
      {% end %}

      {% for key, value in map %}
        def {{key.id}}
          {% type = "JSONApi::To#{value[:to].id.camelcase}Relationship".id %}
          @{{key.id}} ||= {{type}}.new(
            {{key.id.stringify}},
            {{value[:type].id.stringify}},
            {% if value[:key] %}
              {{value[:key].id}},
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

      def get_relationships
        {
          {% for key, value in map %}
            {% if value[:key] %}
              {{key.id}}: {
                type: {{value[:type].id.stringify}},
                key: {{value[:key]}}
              }
            {% end %}
          {% end %}
        }
      end

      {% for key, value in map %}
        {% if value[:key] %}
          private def update_{{key.id}}(pull)
            pull.read_object do |key|
              case key
              when "data"
                {% if value[:to] == "many" %}
                  index = 0
                  ids = [] of String
                  pull.read_array do
                {% end %}
                pull.read_object do |key|
                  path =
                    {% if value[:to] == "many" %}
                      "/data/relationships/{{key.id}}/#{index}/data/type"
                    {% else %}
                      "/data/relationships/{{key.id}}/data/type"
                    {% end %}
                  case key
                  when "type"
                    type = pull.read_string
                    unless type == {{value[:type].id.stringify}}
                      raise JSONApi::UnexpectedTypeError.new(
                        type, {{value[:type].id.stringify}}, path
                      )
                    end
                  when "id"
                    {% if value[:to] == "many" %}
                      ids << pull.read_string
                    {% else %}
                      {{value[:key].id}} = pull.read_string
                    {% end %}
                  else pull.skip
                  end
                end
              else pull.skip
              end
            end

            {% type = "JSONApi::To#{value[:to].id.camelcase}Relationship".id %}
            @{{key.id}} = {{type}}.new(
              {{key.id.stringify}},
              {{value[:type].id.stringify}},
              {{value[:key].id}},
              self_link
            )
          end
        {% end %}
      {% end %}

      def update_relationships(pull)
        pull.read_object do |key|
          case key
          {% for key, value in map %}
            when {{key.id.stringify}}
              {% if value[:key] %}
                update_{{key.id}}(pull)
              {% end %}
          {% end %}
          else pull.skip
          end
        end
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

      def get_attributes
        {
          {% for key, value in map %}
            {{key.id}}: {{key.id}},
          {% end %}
        }
      end

      def update_attributes(pull)
        pull.read_object do |key|
          case key
          {% for key, value in map %}
            when {{key.id.stringify}} then @{{key.id}} =
              {% if value[:nilable] == true %} pull.read_null_or { {% end %}
              {{value[:type]}}.new(pull)
              {% if value[:nilable] == true %} } {% end %}
          {% end %}
          else pull.skip
          end
        end
      end
    end

    def update(pull)
      pull.read_object do |key|
        case key
        when "data"
          pull.read_object do |key|
            case key
            when "attributes" then update_attributes(pull)
            when "relationships" then update_relationships(pull)
            else pull.skip
            end
          end
        else pull.skip
        end
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
