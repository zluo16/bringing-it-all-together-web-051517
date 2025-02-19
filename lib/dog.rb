require "pry"

class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize(dog_hash)
    @name = dog_hash[:name]
    @breed = dog_hash[:breed]
    @id = nil
    if dog_hash[:id]
      @id = dog_hash[:id]
    end
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
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
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.new_from_db(row)
    hash = {:name=>row[1], :breed=>row[2], :id=>row[0]}
    new_dog = self.new(hash)
    new_dog
  end

  def self.create(hash)
    dog = self.new(hash)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL

    dog = DB[:conn].execute(sql, id)[0]
    found_dog = self.new_from_db(dog)
    found_dog
  end

  def self.find_or_create_by(info)
    if self.find_by_name(info[:name]) && self.find_by_breed(info[:breed])
      return self.find_by_name(info[:name])
    else
      new_dog = self.create(info)
      return new_dog
    end
  end

  def self.find_by_breed(breed)
    sql = <<-SQL
      SELECT * FROM dogs WHERE breed = ?
    SQL

    DB[:conn].execute(sql, breed).map{|dog| self.new_from_db(dog)}[0]
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
    SQL

    dog = DB[:conn].execute(sql, name)[0]
    found_dog = self.new_from_db(dog)
    found_dog
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ?
    SQL

    DB[:conn].execute(sql, self.name, self. breed)
  end

end
