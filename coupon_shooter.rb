require 'rubygems'
require 'sinatra'
require "sinatra/reloader" if development?
require 'sinatra/activerecord'
require 'active_support/all'
require 'pry-remote'
require 'EyeEmConnector'
require 'a2_printer'

require './models/coupon'
require './config/environments'


get '/coupons' do
  haml :coupons
end

get '/coupons/:id' do
  haml :coupon

end

post '/coupons' do
  redirect '/coupons'
end

get '/coupons/new' do
  haml :coupons
end

get '/' do
  'Hi!'
end
