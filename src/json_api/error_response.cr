require "./response"
require "./error"

module JSONApi
  abstract class ErrorResponse < Response
    def self.new(error : Error, status_code)
      new([error], status_code)
    end

    def initialize(@errors : Array(Error), status_code)
      super(status_code)
    end

    protected def serialize_data(object, io)
    end

    protected def serialize_included(object, io)
    end

    protected def serialize_errors(object, io)
      object.field(:errors) do
        io.json_array do |errors_array|
          @errors.each do |error|
            errors_array << error
          end
        end
      end
    end
  end
end
