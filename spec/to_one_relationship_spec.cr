require "./spec_helper"

record ResourceMock, id do
  def self_link
    "#{API_ROOT}/resource_mocks/#{@id}"
  end
end

class TestToOneRelationship < JSONApi::ToOneRelationship
  def initialize
    super("other_resources", "resource_mocks", 2, ResourceMock.new(1).self_link)
  end
end

describe JSONApi::ToOneRelationship do
  context "#to_json" do
    it "contains a correct data object" do
      relationship = TestToOneRelationship.new
      type, id = { nil, nil }
      json_object(relationship) do |key, pull|
        case(key)
        when "data"
          pull.read_object do |key|
            case(key)
            when "type" then type = pull.read_string
            when "id" then id = pull.read_string
            else raise("unsupported key #{key}")
            end
          end
        else pull.skip
        end
      end

      type.should eq("resource_mocks")
      id.should eq("2")
    end

    it "sets the relationship data to null if id is nil" do
      relationship = JSONApi::ToOneRelationship.new(
        "other_resources",
        "resource_mocks",
        nil
      )

      json_object(relationship) do |key, pull|
        case(key)
        when "data"
          pull.read_null
        else pull.skip
        end
      end
    end

    it "contains a correct links object" do
      relationship = TestToOneRelationship.new
      self_link, related_link = { nil, nil }
      json_object(relationship) do |key, pull|
        case(key)
        when "links"
          pull.read_object do |key|
            case(key)
            when "self" then self_link = pull.read_string
            when "related" then related_link = pull.read_string
            else raise("unsupported key #{key}")
            end
          end
        else pull.skip
        end

        self_link.should eq("/api_test/v1/resource_mocks/1/relationships/other_resources")
        related_link.should eq("/api_test/v1/resource_mocks/1/other_resources")
      end
    end
  end
end
