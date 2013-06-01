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
        @last_photo = EyeEmConnector.album_photos(5407238)['photos']['items'].first
        pp @last_photo

        begin
          c = SerialConnection.new('/dev/ttyAMA0')
          printer = A2Printer.new(sc)

          printer.begin(200)
          printer.feed(3)
          printer.bold_on
          printer.println("New Photo by #{@last_photo['user']['nickname']}")
          printer.bold_off
          printer.println(@last_photo['caption'])
          printer.println(@last_photo['webUrl'])
          printer.feed(3)
        rescue
          puts 'no printer attached'
        ensure
          file.close unless file.nil?
        end
      else
        puts 'nothing new'
      end
      sleep 10
    end while true
  end
end