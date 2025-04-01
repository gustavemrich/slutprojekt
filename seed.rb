require_relative 'database'

# Clear existing data
Database.clear_all

# Seed the database with sample data
toyota = Database.create_brand("Toyota")
ford = Database.create_brand("Ford")

camry = Database.create_car("Camry", 25000, toyota['id'], "camry.png")
mustang = Database.create_car("Mustang", 35000, ford['id'], "mustang.png")

engine = Database.create_part(1)  # Category 1: Engine
tires = Database.create_part(2)   # Category 2: Tires

Database.create_car_part(camry['id'], engine['id'])
Database.create_car_part(camry['id'], tires['id'])

# Create a test user
Database.create_user("testuser", "password123")

puts "Database seeded successfully!"

# Print the current state of the database
puts "\n=== Current Database State ==="

# Print Brands
puts "\nBrands:"
Database.all_brands.each do |brand|
  puts "ID: #{brand['id']}, Name: #{brand['name']}"
end

# Print Cars with Brand Name
puts "\nCars:"
Database.all_cars.each do |car|
  puts "ID: #{car['id']}, Name: #{car['name']}, Price: #{car['price']}, Brand: #{Database.car_brand(car)&.fetch('name', 'Unknown')}, Image Path: #{car['image_path']}"
end

# Print Parts
puts "\nParts:"
Database.all_parts.each do |part|
  puts "ID: #{part['id']}, Category ID: #{part['cat_id']}"
end

# Print CarParts with Car and Part Names
puts "\nCarParts:"
Database.all_car_parts.each do |car_part|
  car = Database.find_car(car_part['car_id'])
  part = Database.find_part(car_part['part_id'])
  puts "Car: #{car&.fetch('name', 'Unknown')} (ID: #{car_part['car_id']}), Part Category ID: #{part&.fetch('cat_id', 'Unknown')} (ID: #{car_part['part_id']})"
end

# Print Users
puts "\nUsers:"
Database.all_users.each do |user|
  puts "ID: #{user['id']}, Username: #{user['username']}, Password Digest: #{user['pwdigest']}"
end

puts "\n=== End of Database State ==="