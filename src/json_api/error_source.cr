require "json"
require "./cacheable"

module JSONApi
  class ErrorSource
    include Cacheable

    def initialize(pointer = nil : String?, parameter = nil : String?)
      raise "either pointer or parameter must be specified" unless pointer || parameter
      @pointer = pointer
      @parameter = parameter
    end

    def to_cached_json(io)
      io.json_object do |object|
        @pointer.try { |pointer| object.field(:pointer, pointer) }
        @parameter.try { |parameter| object.field(:parameter, parameter) }
      end
    end
  end
end
