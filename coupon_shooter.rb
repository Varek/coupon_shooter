require 'rubygems'
require 'sinatra'
require "sinatra/reloader" if development?
require 'sinatra/activerecord'
require 'active_support/all'
require 'pry-remote'
require 'EyeEmConnector'
require 'a2_printer'
require 'pp'

require './models/coupon'
require './models/coupon_provider'
require './config/environments'


get '/coupons' do
  @coupons = Coupon.all
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
