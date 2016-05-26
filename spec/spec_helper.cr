require "spec"

API_ROOT = "/api_test/v1"

require "../src/json_api"

def json_object(serializer)
  pull = JSON::PullParser.new(serializer.to_json)
  pull.read_object do |key|
    yield(key, pull)
  end
end

def json_object(serializer)
  pull = JSON::PullParser.new(serializer.to_json)
  pull.read_object do |key|
    pull.skip
  end
end

class ResourceMock < JSONApi::Resource
  def initialize(@id : Int32)
  end

  def self.type
    "resource_mocks"
  end

  def self_link
    "#{API_ROOT}/resource_mocks/#{@id}"
  end

  def to_json(io)
    io.json_object do |object|
      object.field(:id, @id.to_s)
    end
  end
end

class TestToManyRelationship < JSONApi::ToManyRelationship
  def initialize
    super("other_resources", "resource_mocks", [1,2,3], ResourceMock.new(1).self_link)
  end
end

class TestToManyRelationshipWithoutIds < JSONApi::ToManyRelationship
  def initialize
    super("other_resources", "resource_mocks", resource_link: ResourceMock.new(1).self_link)
  end
end

class TestToOneRelationship < JSONApi::ToOneRelationship
  def initialize
    super("other_resources", "resource_mocks", 2, ResourceMock.new(1).self_link)
  end
end

class TestToOneRelationshipWithoutId < JSONApi::ToOneRelationship
  def initialize
    super("other_resources", "resource_mocks", resource_link: ResourceMock.new(1).self_link)
  end
end

class TestErrorResponse < JSONApi::ErrorResponse
  protected def serialize_links(object, io)
  end
end
