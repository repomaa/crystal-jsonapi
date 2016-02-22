require "./spec_helper"

describe JSONApi::ErrorSource do
  context "new" do
    it "raises if neither pointer nor parameter is given" do
      expect_raises do
        JSONApi::ErrorSource.new
      end
    end
  end

  context "to_json" do
    it "returns a correct json object" do
      source = JSONApi::ErrorSource.new("/foo/bar")
      source.to_json.should eq(%<{"pointer":"/foo/bar"}>)
      source = JSONApi::ErrorSource.new(parameter: "foo_bar")
      source.to_json.should eq(%<{"parameter":"foo_bar"}>)
    end
  end
end
