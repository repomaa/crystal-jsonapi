require "./spec_helper"

describe JSONApi::RelationshipResponse do
  context "new" do
    it "takes a resource_link and a relationship as its arguments" do
      JSONApi::RelationshipResponse.new("/tests/1", TestToOneRelationship.new)
    end
  end

  context "to_json" do
    it "adds a correct links object" do
      request = JSONApi::RelationshipResponse.new("/tests/1", TestToOneRelationship.new)
      self_link = nil
      related_link = nil

      json_object(request) do |key, pull|
        case(key)
        when "links"
          pull.read_object do |key|
            case(key)
            when "self" then self_link = pull.read_string
            when "related" then related_link = pull.read_string
            else pull.skip
            end
          end
        else pull.skip
        end
      end

      self_link.should eq("/tests/1/relationships/other_resources")
      related_link.should eq("/tests/1/other_resources")
    end

    it "adds the relationship data as data" do
      request = JSONApi::RelationshipResponse.new("/tests/1", TestToOneRelationship.new)

      id = nil
      type = nil
      json_object(request) do |key, pull|
        case(key)
        when "data"
          pull.read_object do |key|
            case(key)
            when "id" then id = pull.read_string
            when "type" then type = pull.read_string
            else pull.skip
            end
          end
        else pull.skip
        end
      end

      id.should eq("2")
      type.should eq("resource_mocks")
    end
  end
end
