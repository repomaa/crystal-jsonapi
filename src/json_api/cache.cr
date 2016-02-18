module JSONApi
  class Cache
    class Record < MemoryIO
      getter last_accessed

      def initialize(@copy_io)
        super()
        yield self
        @last_accessed = Time.now
      end

      def write(slice)
        super
        @copy_io.write(slice)
      end

      def read(slice)
        @last_accessed = Time.now
        super
      end
    end

    def self.instance
      @@instance || setup_with_size(2**10)
    end

    def self.setup_with_size(size)
      @@instance.try { instance.clear }
      @@instance = new(size)
    end

    getter current_size, hit_count, miss_count

    def initialize(@max_size)
      @cache = {} of Int32 => Record
      @current_size = 0
      @hit_count = 0_u32
      @miss_count = 0_u32
      @delete_count = (@max_size * 0.01).ceil.to_i
    end

    def clear
      @cache.clear
    end

    def hit_ratio
      @hit_count / (@hit_count + @miss_count).to_f
    end

    def fetch(hash, io, &block : (Record) ->)
      if @cache.has_key?(hash)
        @hit_count += 1
        cache_record = @cache[hash]
        IO.copy(cache_record.rewind, io)
      else
        @miss_count += 1
        cache_record = Record.new(io, &block)
        @cache[hash] = cache_record
        @current_size += cache_record.size
        cleanup
      end
    end

    private def cleanup
      while @current_size > @max_size
        to_delete = @cache.each.take(@delete_count).to_a
        @cache.each.skip(@delete_count).each do |entry|
          index = to_delete.index { |old_entry|
            entry[1].last_accessed < old_entry[1].last_accessed
          }
          to_delete[index] = entry if index
        end
        to_delete.each do |entry|
          @current_size -= entry[1].size
          @cache.delete(entry[0])
        end
      end
    end
  end
end
