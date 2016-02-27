require "./spec_helper"

describe JSONApi::ToManyRelationship do
  context "#to_json" do
    it "contains a correct data object" do
      relationship = TestToManyRelationship.new
      types, ids = { [] of String, [] of String }
      json_object(relationship) do |key, pull|
        case(key)
        when "data"
          pull.read_array do
            pull.read_object do |key|
              case(key)
              when "type" then types << pull.read_string
              when "id" then ids << pull.read_string
              else raise("unsupported key #{key}")
              end
            end
          end
        else pull.skip
        end
      end

      types.should eq(["resource_mocks", "resource_mocks", "resource_mocks"])
      ids.should eq(["1", "2", "3"])
    end

    it "contains a correct links object" do
      relationship = TestToManyRelationship.new
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

    it "omits the data object if no ids are given" do
      relationship = TestToManyRelationshipWithoutIds.new
      json_object(relationship) do |key, pull|
        case(key)
        when "data"
          fail "relationship should contain no data"
        else pull.skip
        end
      end
    end
  end
end
