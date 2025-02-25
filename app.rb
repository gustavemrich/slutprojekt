require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
require 'bcrypt'

get('/') do
  slim('/start')
end

get('/signup') do
  slim(:signup)
end

get('/start') do
  slim(:start)
end