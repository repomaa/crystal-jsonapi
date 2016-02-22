require "../src/json_api"
require "benchmark"

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

  def cache_stats(size, hits, misses)
    String.build do |io|
      io.print "Cache:".ljust(20)
      io.puts %w(Allocated Hits Misses Hit-Ratio).map(&.rjust(15)).join
      io.print " " * 20
      io.puts [
        "#{human(size)}B",
        human(hits),
        human(misses),
        (hits.to_f / (hits + misses)).round(2).to_s
      ].map(&.rjust(15)).join
    end
  end

  def time_stats(seconds, requests)
    String.build do |io|
      io.print "Time:".ljust(50)
      io.puts [
        "#{seconds.round(2)}s",
        "#{human(requests / seconds)}R/s"
      ].map(&.rjust(15)).join
      io.puts "-" * 80
    end
  end

  def stats(seconds, requests, cache_size, cache_hits, cache_misses)
    String.build do |io|
      io.puts cache_stats(cache_size, cache_hits, cache_misses)
      io.puts time_stats(seconds, requests)
    end
  end

  def heading(text, type = "=")
    String.build do |io|
      io.puts(text)
      io.puts(type * 80)
      io.puts
    end
  end

  def h1(text)
    String.build do |io|
      puts "=" * 80
      io << heading(text, "=")
    end
  end

  def h2(text)
    heading(text, "-")
  end

  def bm_heading(cache_size)
    if cache_size == 0
      puts h1("Simulating requests with cache disabled")
    else
      puts h1([
        "Simulating requests using a cache of".ljust(60),
        "#{human(cache_size)}B".rjust(20)
      ].join)
    end
  end

  def collections(requests, collection_size, cache = nil)
    puts h2(
      "#{human(requests)} collection fetches of #{human(collection_size)} " \
      "records each out of a total of #{human(@total_records)} records"
    )

    time = stopwatch {
      requests.times do
        collection = JSONApi::ResourceCollectionResponse.new(
          people.take(collection_size), "#{API_ROOT}/people"
        )
        collection.to_json(@count_io)
      end
    }

    if cache
      puts stats(time.total_seconds, requests, cache.current_size, cache.hit_count, cache.miss_count)
    else
      puts time_stats(time.total_seconds, requests)
    end
  end

  def single_resources(requests, cache = nil)
    puts h2("#{human(requests)} single reasource fetches")
    time = stopwatch {
      people.take(requests).each { |person| person.to_json(@count_io) }
    }

    if cache
      puts stats(time.total_seconds, requests, cache.current_size, cache.hit_count, cache.miss_count)
    else
      puts time_stats(time.total_seconds, requests)
    end
  end

  def mixed(requests, collection_size, cache = nil)
    puts h2("#{human(requests)} randomly mixed fetches (20% collection and 80% single resource)")

    time = stopwatch {
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

    if cache
      puts stats(time.total_seconds, requests, cache.current_size, cache.hit_count, cache.miss_count)
    else
      puts time_stats(time.total_seconds, requests)
    end
  end

  def run_benchmarks(config)
    config.each do |setup|
      cache_size, size_factor = setup
      cache = JSONApi::Cache.setup_with_size(cache_size.to_i)
      fill_people((size_factor * 2**15).to_i)
      bm_heading(cache_size)
      (1..2).each do |i|
        collections(500, (1024 * size_factor).to_i, cache_size == 0 ? nil : cache)
        single_resources(1_000_000, cache_size == 0 ? nil : cache)
        mixed(5000, (1024 * size_factor).to_i, cache_size == 0 ? nil : cache)
        print "Total size of rendered JSON:".ljust(60)
        puts "#{human(@count_io.size)}B".rjust(20)
        puts
        @count_io.reset
        break if cache_size == 0 || i == 2
        puts h2("Second iteration...")
      end
    end
  end
end

util = BenchmarkUtils.new
util.run_benchmarks([
  {0, 1},
  {2**27, 1},
  {0, 4},
  {2**28, 4},
  {0, 8},
  {2**29, 8},
])
