require_relative 'database'

# Har änvant AI för att hjälpa mig fylla databasen med info.

Database.clear_all

toyota = Database.create_brand("Toyota")
ford = Database.create_brand("Ford")

camry = Database.create_car("Camry", 25000, toyota['id'], "camry.png", 1)
mustang = Database.create_car("Mustang", 35000, ford['id'], "mustang.png", 1)

engine = Database.create_part(1) 
wheels = Database.create_part(2)  

Database.create_car_part(camry['id'], engine['id'])
Database.create_car_part(camry['id'], wheels['id'])

testuser = Database.register_user("testuser", "password123", "password123")
Database.update_user_admin(testuser['id'], 1)

regularuser = Database.register_user("regularuser", "pass123", "pass123")

puts "Database seeded successfully!"

puts "\n=== Current Database State ==="

puts "\nBrands:"
Database.all_brands.each do |brand|
  puts "ID: #{brand['id']}, Name: #{brand['name']}"
end
puts "\nCars:"
Database.all_cars.each do |car|
  puts "ID: #{car['id']}, Name: #{car['name']}, Price: #{car['price']}, Brand: #{Database.car_brand(car)&.fetch('name', 'Unknown')}, Image Path: #{car['image_path']}"
end

puts "\nParts:"
Database.all_parts.each do |part|
  puts "ID: #{part['id']}, Category ID: #{part['cat_id']}"
end

puts "\nCarParts:"
Database.all_car_parts.each do |car_part|
  car = Database.find_car(car_part['car_id'])
  part = Database.find_part(car_part['part_id'])
  puts "Car: #{car&.fetch('name', 'Unknown')} (ID: #{car_part['car_id']}), Part Category ID: #{part&.fetch('cat_id', 'Unknown')} (ID: #{car_part['part_id']})"
end

puts "\nUsers:"
Database.all_users.each do |user|
  puts "ID: #{user['id']}, Username: #{user['username']}, Password Digest: #{user['pwdigest']}, Admin: #{user['admin']}"
end

puts "\n=== End of Database State ==="