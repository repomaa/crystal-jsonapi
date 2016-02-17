require "../src/json_api"

API_ROOT = "/example/v1"

class Person < JSONApi::Resource
end

class PeopleRepository
  TEST_DATA = [
    [ 1, "Tim", 25, 2, 3, [4, 5] ],
    [ 2, "Betty", 55, nil, nil, [6, 7] ],
    [ 3, "John", 57, nil, nil, [6, 7] ],
    [ 4, "Jessica", 24, 6, 7, [1] ],
    [ 5, "Paul", 25, 6, 7, [1] ],
    [ 6, "Lisa", 56, nil, nil, [2, 3] ],
    [ 7, "Mark", 58, nil, nil, [2, 3] ],
  ]

  macro def all : Array(Person)
    @all ||= [
    {% for attributes in TEST_DATA %}
      Person.new({{attributes.argify}}),
    {% end %}
    ]
  end

  def children_of(person)
    all.select { |p| [p.mother_id, p.father_id].includes?(person.id) }
  end

  def related_ids(person, relation)
    case(relation)
    when "friends" then person.friend_ids
    when "children" then children_of(person).map(&.id)
    else raise "unknown to many relationship #{relation}"
    end
  end

  def related_id(person, relation)
    case(relation)
    when "mother" then person.mother_id
    when "father" then person.father_id
    else raise "unknown to one relationship #{relation}"
    end
  end
end

$people_repository = PeopleRepository.new

class Person < JSONApi::Resource
  @@type = "people" # needs to be set for irregular plural forms only

  getter name, age, mother_id, father_id, friend_ids, mother, father, friends, children
  def initialize(@id, @name, @age, @mother_id, @father_id, @friend_ids = [] of Int32)
    @mother = JSONApi::ToOneRelationship.new(
      self, $people_repository, "mother", "people"
    )
    @father = JSONApi::ToOneRelationship.new(
      self, $people_repository, "father", "people"
    )
    @friends = JSONApi::ToManyRelationship.new(
      self, $people_repository, "friends", "people"
    )
    @children = JSONApi::ToManyRelationship.new(
      self, $people_repository, "children", "people"
    )
  end

  def attributes(object, io)
    object.field(:name, name)
    object.field(:age, age)
  end

  def relationships(object, io)
    object.field(:mother, mother)
    object.field(:father, father)
    object.field(:friends, friends)
    object.field(:children, children)
  end
end

people = $people_repository.all

puts JSONApi::ResourceCollection.new(people).to_pretty_json
