require 'sinatra'

get "/" do
  require_relative 'app'
  run
  erb :slack
end
