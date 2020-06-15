require 'pry'
class Dog

attr_accessor :name, :breed, :id


def initialize(name:, breed:, id: nil)
  @name = name
  @breed = breed
  @id = id
end


def self.create_table
    sql = "
    CREATE TABLE IF NOT EXISTS dogs(
    id PRIMARY KEY,
    name TEXT,
    breed TEXT
    )
    "

    DB[:conn].execute(sql)
end

def self.drop_table
  sql = "DROP TABLE IF EXISTS dogs"

   DB[:conn].execute(sql)

end

def self.new_from_db
  new_dog = Dog.new(row[1], row[2])
  new_dog.id = row[0]
  new_dog
end


def self.find_by_name(name)
  sql = "SELECT * FROM dogs WHERE name = ?"
  data = DB[:conn].execute(sql, name)[0]
  new_dog = Dog.new(name: data[1], breed: data[2], id: data[0])
  new_dog
end

def self.find_by_id(id)
  sql = "SELECT * FROM dogs WHERE id = ?"
  data = DB[:conn].execute(sql, id)[0]
  new_dog = Dog.new(name: data[1], breed: data[2], id: data[0])
  new_dog
end


def self.new_from_db(hash)
  new_dog = Dog.new(name: hash[1], breed: hash[2], id: hash[0])
  end


def update
   sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
   DB[:conn].execute(sql, self.name, self.breed, self.id)
 end

def save
  if self.id != nil
    self.update
    else
    sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs") [0][0]
      self
  end
end


def self.create(arg)
new_dog = Dog.new(arg)
new_dog.save

end


def self.find_or_create_by(hash)
  sql = "SELECT * FROM dogs WHERE name = ? and breed = ?"
    dog_data = DB[:conn].execute(sql, hash[:name], hash[:breed])
   unless dog_data.empty?
     dog = dog_data[0]
     dog_data = Dog.new(id: dog[0], name: dog[1], breed: dog[2])
    dog_data.save
    else
      dog_data = self.create(hash)
  end
  dog_data
end




end
