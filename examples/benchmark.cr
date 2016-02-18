require "../src/json_api"
require "benchmark"

API_ROOT = "/example/v1"

class Person < JSONApi::Resource
end

class PeopleRepository
  def all
    RandomPersonIterator.new
  end

  class RandomPersonIterator
    include Iterator(Person)
    def initialize
      @current_id = 0
      pull = JSON::PullParser.new(File.open("examples/names.json"))
      @names = [] of String
      pull.read_array { @names << pull.read_string }
    end

    def next
      name = @names.sample
      age = rand(5..85)
      mother_id, father_id, friend_ids = { nil, nil, [] of Int32 }
      if @current_id > 0
        mother_id = rand(0...@current_id)
        father_id = rand(0...@current_id)
        father_id = nil if father_id == mother_id
        rand(0..10).times { friend_ids << rand(0...@current_id) }
      end
      friend_ids.uniq
      Person.new(@current_id, name, age, mother_id, father_id, friend_ids)
    end
  end
end

$people_repository = PeopleRepository.new

class Person < JSONApi::Resource
  @@type = "people" # needs to be set for irregular plural forms only
  cache_key id, attributes, relationships

  getter mother_id, father_id, friend_ids
  def initialize(@id, @name, @age, @mother_id, @father_id, @friend_ids = [] of Int32)
  end

  relationships({
    mother: { to: :one, type: :people },
    father: { to: :one, type: :people },
    friends: { to: :many, type: :people, keys: @friend_ids },
  })

  attributes({
    name: String,
    age: Int32
  })
end

class NopIO
  include IO

  def write(slice)
    #nop
  end

  def read(slice)
    #nop
  end
end

module Util
  extend self

  def human(bytes)
    result = bytes.to_f
    suffix_index = 0
    suffixes = ["  ", "Ki", "Mi", "Gi"]
    while result > 1000
      result /= 1024
      suffix_index += 1
    end
    "#{result.round(2).to_s.rjust(6)} #{suffixes[suffix_index]}"
  end

  def stopwatch
    started = Time.now
    yield
    puts "Time to finish: #{Time.now - started}"
  end
end

class ByteCounter < NopIO
  def initialize
    @count = 0_u64
  end

  def write(slice)
    @count += slice.size
  end

  def report
    "#{Util.human(@count)}B"
  end

  def reset
    @count = 0
  end
end

nop_io = NopIO.new

collection_size = (2**10).to_i

counter = ByteCounter.new
people = $people_repository.all
collection = JSONApi::ResourceCollection.new(people.take(collection_size))
collection.to_json(counter)
puts "serializing #{collection_size} related people (JSON size: #{counter.report})"

[0, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30].each do |power|
  cache_size = (2**power).to_i

  JSONApi::Cache.setup_with_size(cache_size)
  runs = 0
  Benchmark.ips do |x|
    x.report("Using cache size of #{Util.human(cache_size)}B") do
      collection = JSONApi::ResourceCollection.new(people.take(collection_size))
      collection.to_json(nop_io)
      runs += 1
    end
  end

  size = JSONApi::Cache.instance.current_size
  hits = JSONApi::Cache.instance.hit_count
  misses = JSONApi::Cache.instance.miss_count

  puts "Cache stats for #{runs} requests:"
  puts " Allocated        Hits      Misses   Hit-Ratio"
  puts [
    "#{Util.human(size)}B",
    Util.human(hits),
    Util.human(misses),
    JSONApi::Cache.instance.hit_ratio.round(2).to_s
  ].map(&.rjust(9)).join("   ")
  puts
end
