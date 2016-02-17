class TestResource
  getter id, attr_one, attr_two, related_resource_id
  def initialize(@id, @attr_one = nil, @attr_two = nil, @related_resource_id = nil)
  end
end
