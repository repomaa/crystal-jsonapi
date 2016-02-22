require "../src/json_api"

API_ROOT = "/example/v1"

class Person < JSONApi::Resource
end

class PeopleRepository
  TEST_DATA = [
    [ 1, "Tim", 25, 2, 3, [4, 5], [] of Int32 ],
    [ 2, "Betty", 55, nil, nil, [6, 7], [1] ],
    [ 3, "John", 57, nil, nil, [6, 7], [1] ],
    [ 4, "Jessica", 24, 6, 7, [1], [] of Int32 ],
    [ 5, "Paul", 25, 6, 7, [1], [] of Int32 ],
    [ 6, "Lisa", 56, nil, nil, [2, 3], [4, 5] ],
    [ 7, "Mark", 58, nil, nil, [2, 3], [4, 5] ],
  ]

  macro def all : Array(Person)
    @all ||= [
    {% for attributes in TEST_DATA %}
      Person.new({{attributes.argify}}),
    {% end %}
    ]
  end
end

$people_repository = PeopleRepository.new

class Person < JSONApi::Resource
  @@type = "people" # needs to be set for irregular plural forms only

  getter mother_id, father_id, friend_ids, child_ids
  def initialize(
    @id, @name, @age, @mother_id, @father_id,
    @friend_ids = [] of Int32, @child_ids = [] of Int32
  )
  end

  relationships({
    mother: { to: :one, type: :people },
    father: { to: :one, type: :people },
    friends: { to: :many, type: :people, keys: @friend_ids },
    children: { to: :many, type: :people, keys: @child_ids }
  })

  attributes({
    name: String,
    age: Int32
  })
end

people = $people_repository.all

puts JSONApi::ResourceCollectionResponse.new(people, "#{API_ROOT}/people").to_json
