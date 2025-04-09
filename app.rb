require 'sinatra'
require 'slim'
require 'sinatra/reloader'
require_relative 'database'

enable :sessions
set :public_folder, 'public'

helpers do
  def logged_in?
    !session[:id].nil?
  end

  def current_user
    if session[:id]
      user = Database.login_user(session[:username], session[:password])
      user if user && user['id'] == session[:id]
    end
  end

  def admin?
    user = current_user
    user && user['admin'] == 1
  end
end

UNPROTECTED_ROUTES = ['/', '/login', '/register', '/users']

before do
  pass if UNPROTECTED_ROUTES.include?(request.path_info)
  redirect '/login' unless logged_in?
end

before '/admin/*' do
  redirect '/cars' unless admin?
end

get '/cars/:id' do
  @car = Database.find_car(params[:id].to_i)
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

get '/logout' do
  session.clear
  redirect '/login'
end

get '/cars' do
  begin
    @cars = Database.all_cars
    slim :cars
  rescue SQLite3::BusyException => e
    flash[:error] = "The database is currently busy. Please try again later."
    redirect '/cars'
  end
end

get '/newcar' do
  @brands = Database.all_brands
  @form_data = { name: '', price: '', brand_id: '' }
  slim :newcar
end

post '/cars' do
  name = params[:name]
  price = params[:price].to_i
  brand_id = params[:brand_id].to_i
  image = params[:image]

  errors = []
  if name.nil?
    errors << "Name is required."
  end
  if price <= 0
    errors << "Price must be greater than 0."
  end
  if brand_id <= 0 || Database.find_brand(brand_id).nil?
    errors << "Please select a valid brand."
  end

  image_path = nil
  if image && image[:tempfile]
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
    car = Database.create_car(name, price, brand_id, image_path, session[:id])
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
    session[:username] = username
    session[:password] = password
    redirect '/cars'
  else
    @error = "Fel användarnamn eller lösenord"
    slim :login
  end
end

post '/users' do
  username = params[:username]
  password = params[:password]
  password_confirm = params[:password_confirm]

  user = Database.register_user(username, password, password_confirm)
  if user
    session[:id] = user['id']
    session[:username] = username
    session[:password] = password
    redirect '/cars'
  else
    @error = "Lösenorden matchar inte"
    slim :register
  end
end

get '/admin/users' do
  @users = Database.all_users
  slim :admin_users
end

post '/admin/users/:id/delete' do
  user_id = params[:id].to_i
  if user_id == session[:id]
    @error = "You cannot delete yourself."
  else
    Database.delete_user(user_id)
  end
  redirect '/admin/users'
end

post '/admin/users/:id/toggle_admin' do
  user_id = params[:id].to_i
  user = Database.find_user(user_id)
  if user
    new_admin_status = user['admin'] == 1 ? 0 : 1
    Database.update_user_admin(user_id, new_admin_status)
  end
  redirect '/admin/users'
end