class Dog

attr_accessor :name, :breed, :id

  def initialize(name: name, breed: breed, id: nil)
      @name = name
      @breed = breed
      @id = id
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE dogs
    SQL

    DB[:conn].execute(sql)

  end


  def save
    sql = <<-SQL
    INSERT INTO dogs (name, breed)
    VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, name, breed)

    new_dog = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

    dog = Dog.new(name: new_dog[0][1], breed: new_dog[0][2], id: new_dog[0][0])

  end

  def self.create(args)
    dog = Dog.new(name: args[:name], breed: args[:breed], id: args[:id])
    dog.save
    dog

  end

  def self.find_by_id(id)

    sql = <<-SQL
    SELECT * FROM dogs
    WHERE dogs.id = ?
    LIMIT 1
    SQL

    DB[:conn].execute(sql, id)

    new_dog = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

    dog = Dog.new(name: new_dog[0][1], breed: new_dog[0][2], id: new_dog[0][0])

  end

  def self.find_or_create_by(args)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", args[:name], args[:breed])
    if !dog.empty?
      dog_data = dog[0]
      new_dog = Dog.new(name: dog_data[1], breed: dog_data[2], id: dog_data[0])
    else
      new_dog = self.create(name: args[:name], breed: args[:breed], id: args[:id])
    end
    new_dog
  end

  def self.new_from_db(row)
    new_dog = self.new(name: row[1], breed: row[2], id: row[0])
    new_dog
  end

  def self.find_by_name(name)

    sql = <<-SQL
    SELECT * FROM dogs
    WHERE dogs.name = ?
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end


end
