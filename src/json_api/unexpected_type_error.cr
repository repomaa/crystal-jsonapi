require "./error"

module JSONApi
  class UnexpectedTypeError < Error
    def initialize(type, expected, pointer)
      super(
        "1001",
        "unexpected type",
        "unexpected type #{type}. was expecting #{expected}",
        JSONApi::ErrorSource.new(pointer)
      )
    end
  end
end
