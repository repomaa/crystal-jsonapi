require "./spec_helper"

describe JSONApi::Cache do
  context ".instance" do
    it "returns an instance of JSONApi::Cache" do
      JSONApi::Cache.instance.should be_a(JSONApi::Cache)
    end
  end

  context "fetch" do
    cache = JSONApi::Cache.instance
    it "yields a cache record to write new content to" do
      String.build do |io|
        cache.fetch("foo".hash, io, &.<<("bar"))
      end
    end

    it "writes everything written to the record to the given io" do
      result = String.build do |io|
        cache.fetch("bar".hash, io, &.<<("foo"))
      end
      result.should eq("foo")
    end

    it "keeps the cache size under the defined size" do
      JSONApi::Cache.setup_with_size(1024)
      cache = JSONApi::Cache.instance
      (0..100).each do |i|
        String.build do|io|
          cache.fetch(i, io, &.<<(" " * 100))
        end
        (cache.current_size <= 1024).should be_true
      end
      JSONApi::Cache.setup_with_size(2**20)
    end

    it "writes previously stored content to the io" do
      result = String.build do |io|
        cache.fetch("foo".hash, io, &.<<("bar"))
        cache.fetch("bar".hash, io, &.<<("baz"))
        cache.fetch("foo".hash, io) {}
        cache.fetch("bar".hash, io) {}
      end
      result.should eq("barbazbarbaz")
    end
  end
end
