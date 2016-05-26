require "./spec_helper"

class CacheableTest
  include JSONApi::Cacheable

  def initialize(@foo : String, @bar : String)
  end

  def to_cached_json(io)
    io.json_object do |object|
      object.field(:foo, @foo)
      object.field(:bar, @bar)
    end
  end
end

class TimesCalledTest
  include JSONApi::Cacheable

  @@times_called = 0

  def self.times_called
    @@times_called
  end

  def self.reset
    @@times_called = 0
  end

  def initialize(@foo : String, @bar : String)
  end

  def to_cached_json(io)
    @@times_called += 1
    io.json_object do |object|
      object.field(:foo, @foo)
      object.field(:bar, @bar)
    end
  end
end


describe JSONApi::Cacheable do
  context "#to_json" do
    it "writes the json to the given io" do
      test = CacheableTest.new("foo", "bar")
      test.to_json.should eq(%[{"foo":"foo","bar":"bar"}])
    end

    it "calls to_json only once per hash" do
      test = TimesCalledTest.new("foo", "bar")
      other_test = TimesCalledTest.new("foo", "bar")

      test.to_json
      test.to_json
      TimesCalledTest.times_called.should eq(1)
      TimesCalledTest.reset
      other_test.to_json
      TimesCalledTest.times_called.should eq(0)
    end
  end
end
