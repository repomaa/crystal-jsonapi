require "./relationship"
require "./resource_identifier"
require "./cacheable"

module JSONApi
  class ToManyRelationship < Relationship
    def initialize(name, type, @ids : Enumerable, resource_link = nil)
      super(name, type, resource_link)
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
