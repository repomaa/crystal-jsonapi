require "./spec_helper"

describe JSONApi::ResourceCollection do
  context "#to_json" do
    it "returns a json object" do
      resources = [] of ResourceMock
      test_collection = JSONApi::ResourceCollection(ResourceMock).new(resources)
      json_object(test_collection)
    end

    it "contains a correct links object" do
      resources = [] of ResourceMock
      test = JSONApi::ResourceCollection(ResourceMock).new(resources)
      test_link_overridden = JSONApi::ResourceCollection(ResourceMock).new(
        resources, "/api_test/v1/resource_mocks/1/related_resource_mocks"
      )
      self_links = [nil, nil] of String?

      [test, test_link_overridden].each_with_index do |collection, index|
        json_object(collection) do |key, pull|
          case(key)
          when "links"
            pull.read_object do |key|
              case(key)
              when "self" then self_links[index] = pull.read_string
              else pull.skip
              end
            end
          else pull.skip
          end
        end
      end

      self_links[0].should eq("/api_test/v1/resource_mocks")
      self_links[1].should eq("/api_test/v1/resource_mocks/1/related_resource_mocks")
    end
  end

  it "contains a correct data array" do
    resources = [ResourceMock.new(1), ResourceMock.new(2)]
    test = JSONApi::ResourceCollection(ResourceMock).new(resources)

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
end
