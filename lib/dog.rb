class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id:nil, name:, breed:)
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
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs(id,name,breed)
      Values (?,?,?)
    SQL

    DB[:conn].execute(sql,@id,@name,@breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(name:, breed:)
    new_dog = self.new(name:name,breed:breed)
    new_dog.save
    new_dog
  end

  def self.find_by_id(id)
    dog_array = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id).first
    new_dog = self.new(id:dog_array[0],name:dog_array[1],breed:dog_array[2])
    new_dog
  end

  def self.find_or_create_by(name:, breed:)
    a = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    binding.pry
    if a.length > 0
      found_id = a[0][0]
      self.find_by_id(found_id)
    else
      self.create(name: name, breed: breed)
    end
  end

end
