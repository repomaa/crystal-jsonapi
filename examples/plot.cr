require "../src/json_api"

API_ROOT = "/example/v1"

class Person < JSONApi::Resource
end

class RandomPersonIterator
  include Iterator(Person)
  def initialize
    @pos = 0_u64
    pull = JSON::PullParser.new(File.open("examples/names.json"))
    @names = [] of String
    pull.read_array { @names << pull.read_string }
  end

  def next
    name = @names.sample
    age = rand(5..85)
    mother_id, father_id, friend_ids = { nil, nil, [] of Int32 }
    if @pos > 0
      mother_id = rand(0...@pos)
      father_id = rand(0...@pos)
      father_id = nil if father_id == mother_id
      rand(0..10).times { friend_ids << rand(0...@pos) }
    end
    friend_ids.uniq!
    person = Person.new(@pos, name, age, mother_id, father_id, friend_ids)
    @pos += 1
    person
  end
end

class Person < JSONApi::Resource
  @@type = "people" # needs to be set for irregular plural forms only

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

class CountIO
  include IO

  getter size
  def initialize
    @size = 0_u64
  end

  def write(slice)
    @size += slice.size
    #nop
  end

  def read(slice)
    #nop
  end

  def reset
    @size = 0_u64
  end
end

class BenchmarkUtils
  getter people

  def initialize
    @iterator = RandomPersonIterator.new
    @count_io = CountIO.new
    @total_records = 0
    @people = @iterator
  end

  def fill_people(total_records)
    @total_records = total_records
    @people = @iterator.take(@total_records).to_a.each.cycle
  end

  def human(bytes)
    result = bytes.to_f
    suffix_index = 0
    suffixes = ["", "K", "M", "G"]
    while result > 999
      result /= 1000
      suffix_index += 1
    end
    "#{result.round(2)} #{suffixes[suffix_index]}"
  end

  def stopwatch
    started = Time.now
    yield
    Time.now - started
  end

  def collections(requests, collection_size, cache = nil)
    stopwatch {
      requests.times do
        collection = JSONApi::ResourceCollectionResponse.new(
          people.take(collection_size), "#{API_ROOT}/people"
        )
        collection.to_json(@count_io)
      end
    }
  end

  def single_resources(requests, cache = nil)
    stopwatch {
      people.take(requests).each { |person| person.to_json(@count_io) }
    }
  end

  def mixed(requests, collection_size, cache = nil)
    stopwatch {
      requests.times do
        if rand > 0.2
          people.take(1).each { |person| person.to_json(@count_io) }
        else
          collection = JSONApi::ResourceCollectionResponse.new(
            people.take(collection_size), "#{API_ROOT}/people"
          )
          collection.to_json(@count_io)
        end
      end
    }
  end

  def run_benchmarks(config, type)
    config.each do |setup|
      cache_size, size_factor = setup
      cache = JSONApi::Cache.setup_with_size(cache_size.to_i)
      fill_people((size_factor * 2**15).to_i)
      (1..2).each do |i|
        @count_io.reset
        break if cache_size == 0 && i == 2
        requests = 0
        time = case(type)
        when "collections"
          requests = 500
          collections(500, (1024 * size_factor).to_i, cache_size == 0 ? nil : cache)
        when "single_resources"
          requests = 1_000_000
          single_resources(1_000_000, cache_size == 0 ? nil : cache)
        when "mixed"
          requests = 5000
          mixed(5000, (1024 * size_factor).to_i, cache_size == 0 ? nil : cache)
        else raise "invalid request type #{type}"
        end
        next if cache_size > 0 && i == 1
        puts "#{cache_size*2**-20}\t#{@count_io.size*2**-20 / requests}\t#{requests/time.total_seconds}"
      end
    end
  end
end

util = BenchmarkUtils.new

macro reference_params
  [
  {% for i, index in [0.25, 0.5, 0.75, 1, 1.25, 1.5, 2, 3, 4, 6, 8, 10, 12, 16, 20] %}
    {0, {{i}}},
  {% end %}
  ]
end

macro benchmark_params
  [
  {% for i in [0.25, 0.5, 0.75, 1, 1.25] %}
    {2**25, {{i}}},
  {% end %}
  {% for i in [0.25, 0.5, 0.75, 1, 1.25, 1.5, 2] %}
    {2**26, {{i}}},
  {% end %}
  {% for i in [0.25, 0.5, 0.75, 1, 1.25, 1.5, 2, 3, 4] %}
    {2**27, {{i}}},
  {% end %}
  {% for i in [0.25, 0.5, 0.75, 1, 1.25, 1.5, 2, 3, 4, 6, 8] %}
    {2**28, {{i}}},
  {% end %}
  {% for i in [0.25, 0.5, 0.75, 1, 1.25, 1.5, 2, 3, 4, 6, 8, 10, 12] %}
    {2**29, {{i}}},
  {% end %}
  {% for i, index in [0.25, 0.5, 0.75, 1, 1.25, 1.5, 2, 3, 4, 6, 8, 10, 12, 16, 20] %}
    {2**30, {{i}}},
  {% end %}
  ]
end

if ARGV[1]? == "reference"
  util.run_benchmarks(reference_params, ARGV[0])
  exit
end
util.run_benchmarks(benchmark_params, ARGV[0])
