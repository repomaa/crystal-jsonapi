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

record ResourceMock, id do
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
