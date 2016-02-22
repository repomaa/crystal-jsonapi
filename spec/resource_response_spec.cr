require "./spec_helper"

describe JSONApi::ResourceResponse do
  context "new" do
    it "takes a resource as its first argument" do
      JSONApi::ResourceResponse.new(ResourceMock.new(1))
    end
  end

  context "to_json" do
    it "adds a correct links object" do
      request = JSONApi::ResourceResponse.new(ResourceMock.new(1))
      self_link = nil

      json_object(request) do |key, pull|
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

      self_link.should eq("/api_test/v1/resource_mocks/1")
    end

    it "includes other resources passed via included" do
      request = JSONApi::ResourceResponse.new(
        ResourceMock.new(1), included: [ResourceMock.new(2)]
      )

      included_ids = [] of String
      json_object(request) do |key, pull|
        case(key)
        when "included"
          pull.read_array do
            pull.read_object do |key|
              case(key)
              when "id" then included_ids << pull.read_string
              else pull.skip
              end
            end
          end
        else pull.skip
        end
      end

      included_ids.should eq(["2"])
    end
  end
end
