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

set :tmp_folder, Proc.new { File.join(root, "tmp") }
Coupon.tmp_path = settings.tmp_folder

get '/coupons' do
  @coupons = Coupon.all
  haml :coupons
end

get '/coupons/:id' do
  @coupon = Coupon.find(params[:id])
  haml :coupon
end

get '/coupons/:id/print' do
  coupon = Coupon.find(params[:id])
  begin
    coupon.print_photo
  rescue
  end
  redirect "/coupons/#{params[:id]}"
end

post '/coupons' do
  Coupon.create(code: params[:coupon_code], coupon_type: params[:coupon_type], coupon_provider_id: params[:coupon_provider_id])
  redirect '/coupons'
end

get '/' do
  'Hi!'
end
