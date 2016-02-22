require "./response"
require "./error"

module JSONApi
  abstract class ErrorResponse < Response
    def initialize(error : JSONApi::Error)
      @errors = [error]
    end

    def initialize(@errors : (Enumerable(JSONApi::Error) | Iterator(JSONApi::Error)))
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
