require "./spec_helper"

class HasMetaTest
  include JSONApi::HasMeta

  class Meta < JSONApi::Meta
    def initialize(@foo : String, @bar : String)
    end
  end

  def initialize(@meta = nil)
  end

  def to_json(io)
    io.json_object do |object|
      serialize_meta(object, io)
    end
  end
end

describe JSONApi::HasMeta do
  it "provides a protected serialize_meta method" do
    test = HasMetaTest.new

    String.build do |io|
      test.to_json(io)
    end
  end

  it "dosn't add anything to the json object if meta is not defined" do
    test = HasMetaTest.new

    json = String.build do |io|
      test.to_json(io)
    end
    json.should eq("{}")
  end

  it "adds a meta field with the serialized meta object" do
    test = HasMetaTest.new(HasMetaTest::Meta.new("foo", "bar"))

    json = String.build do |io|
      test.to_json(io)
    end
    json.should eq(%<{"meta":{"foo":"foo","bar":"bar"}}>)
  end
end
