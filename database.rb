require 'sqlite3'
require 'bcrypt'

module Database
  # Define the connection as a module-level variable
  @db = nil

  module_function

  def connection
    @db ||= SQLite3::Database.new('db/db.db').tap do |db|
      db.results_as_hash = true
    end
  end

  def execute(query, *params)
    connection.execute(query, params)  # Pass params as a single array
  end

  def execute_query(query, *params)
    connection.execute(query, params)  # Pass params as a single array
  end

  def last_insert_row_id
    connection.last_insert_row_id
  end

  # === Brand Operations ===
  def all_brands
    execute_query("SELECT * FROM brands")
  end

  def find_brand(id)
    execute_query("SELECT * FROM brands WHERE id = ?", id).first
  end

  def create_brand(name)
    execute("INSERT INTO brands (name) VALUES (?)", name)
    { 'id' => last_insert_row_id, 'name' => name }
  end

  # === Car Operations ===
  def all_cars
    execute_query("SELECT * FROM cars")
  end

  def find_car(id)
    execute_query("SELECT * FROM cars WHERE id = ?", id).first
  end

  def create_car(name, price, brand_id, image_path)
    execute(
      "INSERT INTO cars (name, price, brand_id, image_path) VALUES (?, ?, ?, ?)",
      name, price, brand_id, image_path
    )
    { 'id' => last_insert_row_id, 'name' => name, 'price' => price, 'brand_id' => brand_id, 'image_path' => image_path }
  end

  def car_brand(car)
    find_brand(car['brand_id'])
  end

  def car_parts(car)
    execute_query(
      "SELECT parts.* FROM parts
       JOIN car_parts ON parts.id = car_parts.part_id
       WHERE car_parts.car_id = ?",
      car['id']
    )
  end

  # === CarPart Operations ===
  def create_car_part(car_id, part_id)
    execute(
      "INSERT INTO car_parts (car_id, part_id) VALUES (?, ?)",
      car_id, part_id
    )
    { 'car_id' => car_id, 'part_id' => part_id }
  end

  def all_car_parts
    execute_query("SELECT * FROM car_parts")
  end

  # === Part Operations ===
  def create_part(cat_id)
    execute(
      "INSERT INTO parts (cat_id) VALUES (?)",
      cat_id
    )
    { 'id' => last_insert_row_id, 'cat_id' => cat_id }
  end

  def find_part(id)
    execute_query("SELECT * FROM parts WHERE id = ?", id).first
  end

  def all_parts
    execute_query("SELECT * FROM parts")
  end

  # === User Operations ===
  def register_user(username, password, password_confirm)
    if password == password_confirm
      pwdigest = BCrypt::Password.create(password)
      execute(
        "INSERT INTO users (username, pwdigest) VALUES (?, ?)",
        username, pwdigest
      )
      { 'id' => last_insert_row_id, 'username' => username, 'pwdigest' => pwdigest }
    else
      nil  # Return nil to indicate failure
    end
  end

  def login_user(username, password)
    user = execute_query("SELECT * FROM users WHERE username = ?", username).first
    if user && BCrypt::Password.new(user['pwdigest']) == password
      user
    else
      nil  # Return nil to indicate failure
    end
  end

  def all_users
    execute_query("SELECT * FROM users")
  end

  # === Clear Database ===
  def clear_all
    execute("DELETE FROM brands")
    execute("DELETE FROM cars")
    execute("DELETE FROM car_parts")
    execute("DELETE FROM parts")
    execute("DELETE FROM users")
  end
end