require "./spec_helper"

describe JSONApi::ResourceIdentifier do
  context ".new" do
    it "receives a type and an id" do
      JSONApi::ResourceIdentifier.new("test", 1)
    end
  end

  context "#to_json" do
    it "returns a json object" do
      identifier = JSONApi::ResourceIdentifier.new("test", 1)
      json_object(identifier)
    end

    it "contains the type" do
      identifier = JSONApi::ResourceIdentifier.new("test", 1)
      type = nil
      json_object(identifier) do |key, pull|
        case(key)
        when "type" then type = pull.read_string
        else pull.skip
        end
      end
      type.should eq("test")
    end

    it "contains the stringified id" do
      identifier = JSONApi::ResourceIdentifier.new("test", 1)
      id = nil
      json_object(identifier) do |key, pull|
        case(key)
        when "id" then id = pull.read_string
        else pull.skip
        end
      end
      id.should eq("1")
    end
  end
end
