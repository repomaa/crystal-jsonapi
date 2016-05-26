require "./spec_helper"

class TestMeta < JSONApi::Meta
  def initialize(@foo : String, @bar : String)
  end
end

describe JSONApi::Meta do
  context "#to_json" do
    it "renders an json object with its instance variables" do
      TestMeta.new("foo", "bar").to_json.should eq(%<{"foo":"foo","bar":"bar"}>)
    end
  end
end
