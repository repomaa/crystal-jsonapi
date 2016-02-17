require "./spec_helper"

class TestResource < JSONApi::Resource
  def initialize(@id)
  end
end

class AttributesTestResource < JSONApi::Resource
  def initialize(@id, @attr_one, @attr_two)
  end

  def attributes(object, io)
    object.field(:attr_one, @attr_one)
    object.field(:attr_two, @attr_two)
  end
end

record RelationshipMock, foo do
  def to_json(io)
    io.json_object do |object|
      object.field(:foo, @foo)
    end
  end
end

class RelationshipsTestResource < JSONApi::Resource
  def initialize(@id, @relationship)
  end

  def relationships(object, io)
    object.field(:related_test, @relationship)
  end
end

describe JSONApi::Resource do
  context ".to_json" do
    it "returns a json object" do
      resource = TestResource.new(1)
      json_object(resource)
    end

    it "adds a correct type field" do
      resource = TestResource.new(1)
      type = nil
      json_object(resource) do |key, pull|
        case(key)
        when "type" then type = pull.read_string
        else pull.skip
        end
      end

      type.should eq("test_resources")
    end

    it "adds a stringified id field" do
      resource = TestResource.new(1)
      id = nil
      json_object(resource) do |key, pull|
        case(key)
        when "id" then id = pull.read_string
        else pull.skip
        end
      end

      id.should eq("1")
    end

    it "doesn't add unsupported fields" do
      resource = TestResource.new(1)
      expected_fields = ["type", "id", "attributes", "relationships", "links", "meta"]
      json_object(resource) do |key, pull|
        (expected_fields.includes?(key)).should be_true
        pull.skip
      end
    end

    it "adds an attributes object if attributes is implemented" do
      resource = AttributesTestResource.new(1, "foo", 2)
      attr_one, attr_two = { nil, nil }
      json_object(resource) do |key, pull|
        case(key)
        when "attributes"
          pull.read_object do |attribute|
            attr_one = pull.read_string if attribute == "attr_one"
            attr_two = pull.read_int if attribute == "attr_two"
          end
        else pull.skip
        end
      end

      attr_one.should eq("foo")
      attr_two.should eq(2)
    end

    it "adds a correct links object" do
      resource = TestResource.new(1)
      self_link = nil

      json_object(resource) do |key, pull|
        case(key)
        when "links"
          pull.read_object do |key|
            case(key)
            when "self" then self_link = pull.read_string
            else pull.skip
            end
          end
        else pull.skip
        end
      end

      self_link.should eq("/api_test/v1/test_resources/1")
    end

    it "adds an relationships object if relationships is implemented" do
      resource = RelationshipsTestResource.new(1, RelationshipMock.new("bar"))
      test_value = nil
      json_object(resource) do |key, pull|
        case(key)
        when "relationships"
          pull.read_object do |key|
            case(key)
            when "related_test"
              pull.read_object do |key|
                case(key)
                when "foo" then test_value = pull.read_string
                else pull.skip
                end
              end
            else pull.skip
            end
          end
        else pull.skip
        end
      end
      test_value.should eq("bar")
    end
  end
end
