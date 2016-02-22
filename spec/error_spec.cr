require "./spec_helper"

describe JSONApi::Error do
  context "to_json" do
    it "returns a correct json object" do
      code = nil
      title = nil
      json_object(JSONApi::Error.new("123", "An error occured")) do |key, pull|
        case(key)
        when "code" then code = pull.read_string
        when "title" then title = pull.read_string
        else raise "unexpected key #{key}"
        end
      end
      code.should eq("123")
      title.should eq("An error occured")
    end

    it "includes detail if provided" do
      detail = nil

      json_object(JSONApi::Error.new("123", "An error occured", detail: "foobar")) do |key, pull|
        case(key)
        when "detail" then detail = pull.read_string
        else pull.skip
        end
      end
      detail.should eq("foobar")
    end

    it "includes error source if provided" do
      source_pointer = nil

      source = JSONApi::ErrorSource.new("/foo/bar")
      json_object(JSONApi::Error.new("123", "An error occured", source: source)) do |key, pull|
        case(key)
        when "source"
          pull.read_object do |key|
            case(key)
            when "pointer" then source_pointer = pull.read_string
            else raise "unexpected key #{key}"
            end
          end
        else pull.skip
        end
      end
      source_pointer.should eq("/foo/bar")
    end
  end
end
