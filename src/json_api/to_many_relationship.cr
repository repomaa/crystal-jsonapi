require "./relationship"
require "./resource_identifier"
require "./cacheable"

module JSONApi
  class ToManyRelationship < Relationship
    def initialize(resource_link, name, type, @ids : Enumerable)
      super(resource_link, name, type)
    end

    protected def serialize_data(io)
      io.json_array do |array|
        @ids.each do |id|
          array << ResourceIdentifier.new(@type, id)
        end
      end
    end
  end
end
