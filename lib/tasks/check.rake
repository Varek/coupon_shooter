namespace :coupon_shooter do

  desc "fetch data from authenticated services and write them to evernote"
  task :check_and_print do
    @eye_em = EyeEmConnector.configure do |config|
      config.client_id = ENV['EYEEM_KEY']
      config.client_secret = ENV['EYEEM_SECRET']
    end

    #puts ENV['EYEEM_KEY']
    @last_updated = EyeEmConnector.album(5407238)['album']['updated']
    @last_photo = EyeEmConnector.album_photos(5407238)['photos']['items'].first

    begin
      puts 'check album'
      updated = EyeEmConnector.album(5407238)['album']['updated']
      if updated > @last_updated
        puts "album updated: #{@last_updated}"
        @last_updated = updated
        @last_photo = EyeEmConnector.album_photos(5407238, detailed: true)['photos']['items'].first
        coupon = Coupon.where('printed IS NOT TRUE').first
        pp @last_photo
        coupon.username = @last_photo['user']['nickname']
        coupon.user_id = @last_photo['user']['id']
        coupon.photo_id = @last_photo['id']
        coupon.save
        begin
          sc = SerialConnection.new('/dev/ttyAMA0')
          printer = A2Printer.new(sc)
          coupon = Coupon.where(:printed => nil)

          printer.begin(200)
          printer.feed(3)
          printer.bold_on
          printer.justify(1)
          printer.double_width_on
          printer.set_size(:large)
          printer.println("Voucher")
          printer.println("for")
          printer.println(coupon.coupon_provider.name)
          printer.set_size(:small)
          printer.double_width_off
          printer.println("(#{coupon.coupon_provider.url})")
          printer.feed(2)
          printer.set_size(:normal)
          printer.println(coupon.coupon_type)
          printer.println('with the code')
          printer.double_width_on
          printer.bold_on
          printer.println(coupon.code)
          printer.double_width_off
          printer.bold_off
          printer.justify(0)
          printer.println("created for @#{coupon.username}")
          printer.feed(2)
          printer.set_size(:small)
          printer.println("powered by CouponShooter")
          #printer.println("received for @#{coupon.username}")
          #printer.double_width_on
          #printer.bold_off
          #printer.println(@last_photo['caption'])
          #printer.println(@last_photo['webUrl'])
          printer.feed(3)
          coupon.update_attribute(:printed, true)
        rescue
          puts 'no printer attached'
        ensure
        end
      else
        puts 'nothing new'
      end
      sleep 5
    end while true
  end
end