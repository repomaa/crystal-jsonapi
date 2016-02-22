require "./spec_helper"

describe JSONApi::ResourceCollectionResponse do
  context "#to_json" do
    it "returns a json object" do
      resources = [] of ResourceMock
      test_collection = JSONApi::ResourceCollectionResponse.new(resources, "/")
      json_object(test_collection)
    end

    it "contains a correct links object" do
      resources = [] of ResourceMock
      test_link = JSONApi::ResourceCollectionResponse.new(
        resources, "/api_test/v1/resource_mocks/1/related_resource_mocks"
      )
      self_link = nil

      json_object(test_link) do |key, pull|
        case(key)
        when "links"
          pull.read_object do |key|
            case(key)
            when "self" then self_link = pull.read_string
            else pull.skip
            end
          end
        else pull.skip
        end
      end

      self_link.should eq("/api_test/v1/resource_mocks/1/related_resource_mocks")
    end
  end

  it "contains a correct data array" do
    resources = [ResourceMock.new(1), ResourceMock.new(2)]
    test = JSONApi::ResourceCollectionResponse.new(resources, "/")

    ids = [] of String
    json_object(test) do |key, pull|
      case(key)
      when "data"
        pull.read_array do
          pull.read_object do |key|
            case(key)
            when "id" then ids << pull.read_string
            else pull.skip
            end
          end
        end
      else pull.skip
      end
    end

    ids.should eq(["1", "2"])
  end

  context "included" do
    it "has an optional included param for included resources" do
      test = JSONApi::ResourceCollectionResponse.new(
        [] of ResourceMock, "/", included: [ResourceMock.new(1)]
      )
      ids = [] of String
      json_object(test) do |key, pull|
        case(key)
        when "included"
          pull.read_array do
            pull.read_object do |key|
              case(key)
              when "id" then ids << pull.read_string
              else pull.skip
              end
            end
          end
        else pull.skip
        end
      end
      ids.should eq(["1"])
    end
  end
end
