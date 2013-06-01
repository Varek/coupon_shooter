require 'rubygems'
require 'sinatra'
require "sinatra/reloader" if development?
require 'sinatra/activerecord'
require 'active_support/all'
require 'pry-remote'
require 'EyeEmConnector'
require 'a2_printer'
require 'pp'
require "RMagick"
include Magick

require './models/coupon'
require './models/coupon_provider'
require './config/environments'

EyeEmConnector.configure do |config|
  config.client_id = ENV['EYEEM_KEY']
  config.client_secret = ENV['EYEEM_SECRET']
end

set :public_folder, Proc.new { File.join(root, "tmp") }
Coupon.tmp_path = settings.public_folder

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
