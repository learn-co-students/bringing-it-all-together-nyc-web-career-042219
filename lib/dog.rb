
require 'pry'
class Dog

	attr_accessor :id, :name, :breed

	def initialize(dog_hash)
		@id = dog_hash[:id]
		@name = dog_hash[:name]
		@breed = dog_hash[:breed]
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
		DROP TABLE IF EXISTS dogs
		SQL
		DB[:conn].execute(sql)
	end

	def save
		if id
			update
		else
		sql = <<-SQL 
			INSERT INTO dogs (name, breed)
			VALUES (?, ?)
		SQL
		DB[:conn].execute(sql, name, breed)
		self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
		self.class.find_by_id(id)	
	end
	end

	def update
		sql = <<-SQL
		UPDATE dogs
		SET name = ?, breed = ?
		SQL
		DB[:conn].execute(sql, name, breed)
	end

	def self.create(hash)
		new_dog = Dog.new(hash)
		new_dog.save
		new_dog
	end

	def self.find_by_id(id)
		self.all.find {|dog| dog.id == id}
	end

	def self.new_from_db(row)
		Dog.new(id:row[0], name:row[1], breed:row[2])
	end

	def self.find_by_name(name)
		sql = <<-SQL
			SELECT *
			FROM dogs
			WHERE name = ?
		SQL
		DB[:conn].execute(sql, name).map do |row|
			self.new_from_db(row)
		end.first
	end

	  def self.find_or_create_by(hash)
    	unless find_by_name_and_breed(hash[:name], hash[:breed]).nil?
      		dog = find_by_name_and_breed(hash[:name], hash[:breed])
    	else
      		dog = create(hash)
    	end
    	binding.pry
    	dog
  		end


	private

	def self.all
		sql = <<-SQL
		SELECT *
		FROM dogs
		SQL
		DB[:conn].execute(sql).map {|row| new_from_db(row)}
	end

	 def self.find_by_name_and_breed(name, breed)
    	all.find { |dog| dog.class.find_by_name(name) && dog.breed == breed }     
  	end
end