require 'sinatra'
require 'slim'
require 'sinatra/reloader'
require_relative 'database'

enable :sessions
set :public_folder, 'public'

# Routes
get '/cars/:id' do
  @car = Database.find_car(params[:id])
  halt 404, "Car not found" unless @car
  slim :car_details
end

get '/' do
  slim '/start'
end

get '/register' do
  slim :register
end

get '/login' do
  slim :login
end

get '/cars' do
  begin
    @cars = Database.all_cars
    slim :cars
  rescue SQLite3::BusyException => e
    @error = "The database is currently busy. Please try again later."
    slim :error
  end
end

get '/cars/new' do
  @brands = Database.all_brands
  slim :'cars/new'
end

post '/cars' do
  name = params[:name]
  price = params[:price].to_i
  brand_id = params[:brand_id].to_i
  image = params[:image]

  # Handle the uploaded image
  image_path = nil
  if image && image[:tempfile]
    filename = "#{Time.now.to_i}_#{image[:filename]}"
    File.open("public/images/#{filename}", 'wb') do |f|
      f.write(image[:tempfile].read)
    end
    image_path = filename
  end

  # Create the car
  Database.create_car(name, price, brand_id, image_path)
  redirect '/cars'
end

post '/login' do
  username = params[:username]
  password = params[:password]
  user = Database.login_user(username, password)
  if user
    session[:id] = user['id']
    @username = username
    redirect '/logged_in'
  else
    "fel användarnamn eller lösenord"
  end
end

post '/users' do
  username = params[:username]
  password = params[:password]
  password_confirm = params[:password_confirm]

  puts "username: #{username}"
  puts "password: #{password}"
  puts "password_confirm: #{password_confirm}"

  user = Database.register_user(username, password, password_confirm)
  if user
    redirect '/'
  else
    "lösenorden matchar inte"
  end
end