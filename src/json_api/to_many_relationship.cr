require "./relationship"
require "./resource_identifier"
require "./cacheable"
require "./types"

module JSONApi
  class ToManyRelationship < Relationship
    @ids : Array(ID)?
    def initialize(name, type, ids = nil, resource_link = nil)
      super(name, type, resource_link)
      @ids = ids.try &.map &.as(ID)
    end

    protected def serialize_data(object, io)
      return unless ids = @ids
      object.field(:data) do
        io.json_array do |array|
          ids.each do |id|
            array << ResourceIdentifier.new(@type, id)
          end
        end
      end
    end
  end
end
