require "./response"

module JSONApi
  abstract class SuccessResponse < Response
    protected def serialize_errors(object, io)
    end

    protected def serialize_included(object, io)
      @included.try do |included|
        object.field(:included) do
          io.json_array do |array|
            included.each do |resource|
              array << resource
            end
          end
        end
      end
    end
  end
end
