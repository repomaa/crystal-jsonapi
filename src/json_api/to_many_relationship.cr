require "./relationship"
require "./resource_identifier"

module JSONApi
  class ToManyRelationship(T) < Relationship(T)
    protected def serialize_data(io)
      io.json_array do |array|
        @repository.related_ids(@resource, @name).each do |id|
          array << ResourceIdentifier.new(@type, id)
        end
      end
    end
  end
end
