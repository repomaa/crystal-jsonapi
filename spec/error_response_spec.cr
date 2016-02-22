require "./spec_helper"

describe JSONApi::ErrorResponse do
  context "new" do
    it "either takes a single error or a collection of errors" do
      TestErrorResponse.new(JSONApi::Error.new("123", "Foobar"))
      TestErrorResponse.new([JSONApi::Error.new("123", "Foobar")])
    end
  end

  context "to_json" do
    it "returns a json object" do
      response = TestErrorResponse.new(JSONApi::Error.new("123", "Foobar"))
      json_object(response)
    end

    it "add a correct errors array" do
      response = TestErrorResponse.new(JSONApi::Error.new("123", "Foobar"))

      code = nil
      title = nil
      json_object(response) do |key, pull|
        case(key)
        when "errors"
          pull.read_array do
            pull.read_object do |key|
              case(key)
              when "code" then code = pull.read_string
              when "title" then title = pull.read_string
              else pull.skip
              end
            end
          end
        else pull.skip
        end
      end

      code.should eq("123")
      title.should eq("Foobar")
    end
  end
end
