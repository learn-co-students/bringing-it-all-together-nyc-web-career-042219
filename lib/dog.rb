class Dog

  def self.create_table
    DB[:conn].execute(<<-SQL)
    CREATE TABLE dogs(
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )    
    SQL
  end

  def self.drop_table
    DB[:conn].execute(<<-SQL)
    DROP TABLE IF EXISTS dogs
    SQL
  end

  def self.create(dog_hash)
    dog = Dog.new(dog_hash)
    dog.save
    dog
  end

  def self.find_or_create_by(hash)
    # sql = <<-SQL
    # SELECT
    #   *
    # FROM
    #   dogs
    # WHERE
    #   name = ? AND breed = ?
    # SQL
    # dogs = DB[:conn].execute(sql, hash[:name], hash[:breed])
    # if !dog.empty
    unless find_by_name_and_breed(hash[:name], hash[:breed]).nil?
      dog = find_by_name_and_breed(hash[:name], hash[:breed])
    else
      dog = create(hash)
    end
    dog
  end

  def self.new_from_db(row)
    Dog.new(:id => row[0], :name => row[1], :breed => row[2])
  end
  
  def self.find_by_id(id)
    all.find { |dog| dog.id == id }
  end

  def self.find_by_name(name)
    all.find { |dog| dog.name == name}
  end

  attr_accessor  :id, :name, :breed

  def initialize(dog)
    @id = dog[:id]
    @name = dog[:name]
    @breed = dog[:breed]    
  end

  def update
    sql = <<-SQL
    UPDATE
      dogs
    SET
      name = ?,
      breed = ?
    SQL
    DB[:conn].execute(sql, name, breed)
  end

  def save
    if id
      update
    else
      sql = <<-SQL
      INSERT INTO dogs(name, breed)
      VALUES(?, ?)
      SQL
      DB[:conn].execute(sql, name, breed)
      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self.class.find_by_id(id)
    end
  end

  private

  def self.all
    sql = <<-SQL
    SELECT
      *
    FROM
      dogs
    SQL
    DB[:conn].execute(sql).map { |row| new_from_db(row) }
  end

  def self.find_by_name_and_breed(name, breed)
    all.find { |dog| dog.class.find_by_name(name) && dog.breed == breed }     
  end

end