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

get '/newcar' do
  @brands = Database.all_brands
  @form_data = { name: '', price: '', brand_id: '' } unless defined?(@form_data)
  @errors = [] unless defined?(@errors)
  slim :newcar
end

post '/cars' do
  name = params[:name]
  price = params[:price].to_i
  brand_id = params[:brand_id].to_i
  image = params[:image]

  # Validation
  errors = []
  if name.nil? || name.strip.empty?
    errors << "Name is required."
  end
  if price <= 0
    errors << "Price must be greater than 0."
  end
  if brand_id <= 0 || Database.find_brand(brand_id).nil?
    errors << "Please select a valid brand."
  end

  # Handle the uploaded image
  image_path = nil
  if image && image[:tempfile]
    # Validate image type (optional)
    unless ['image/png', 'image/jpeg', 'image/jpg'].include?(image[:type])
      errors << "Image must be a PNG, JPEG, or JPG file."
    else
      filename = "#{Time.now.to_i}_#{image[:filename]}"
      File.open("public/images/#{filename}", 'wb') do |f|
        f.write(image[:tempfile].read)
      end
      image_path = filename
    end
  end

  if errors.empty?
    # Create the car
    car = Database.create_car(name, price, brand_id, image_path)
    if car
      redirect '/cars'
    else
      @errors = ["Failed to create car. Please try again."]
      @brands = Database.all_brands
      @form_data = { name: name, price: price, brand_id: brand_id }
      slim :newcar
    end
  else
    @errors = errors
    @brands = Database.all_brands
    @form_data = { name: name, price: price, brand_id: brand_id }
    slim :newcar
  end
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