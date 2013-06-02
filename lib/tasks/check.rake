namespace :coupon_shooter do

  desc "fetch data from authenticated services and write them to evernote"
  task :check_and_print do

    #puts ENV['EYEEM_KEY']
    #@last_updated = EyeEmConnector.album(5407238)['album']['updated']
    aps = EyeEmConnector.album_photos(5407238,detailed: true)
    @last_photo = aps['photos']['items'].last
    @photo_count = aps['photos']['total'].to_i

    begin
      puts 'check album'
      photos = EyeEmConnector.album_photos(5407238,detailed: true)
      photo = photos['photos']['items'].select{ |a| a['id'].to_i > @last_photo['id'].to_i}.last
      coupon = Coupon.where(:printed => nil).first
      if photo.present? && coupon.present? && Coupon.where(:user_id => photo['user']['id']).where("DATETIME(updated) > ?",Date.today.to_datetime).where("DATETIME(updated) < ?",Date.tomorrow.to_datetime).present?
        puts "#{@last_photo['user']['nickname']}(#{@last_photo['user']['id']}) got already a coupon today"
        begin
          sc = SerialConnection.new('/dev/ttyAMA0')
          printer = A2Printer.new(sc)
          printer.begin(200)
          printer.feed(3)
          printer.bold_on
          printer.justify(:center)
          printer.double_width_on
          printer.set_size(:large)
          printer.println("Sorry,")
          printer.println("you can get")
          printer.println("only one coupon")
          printer.println("a day.")
          printer.feed
          printer.println("But you get")
          printer.println(" a robot.")
          printer.double_width_off
          printer.bold_off
          printer.justify(:left)
          printer.feed
          robot = "             .---.
           ,' - - `.
   _ _____/ <q> <p> \\_____ _
  /_||   ||`-.___.-`||   ||-\\
 / _||===||         ||===|| _\\
|- _||===||=========||===||- _|
\\___||___||_________||___||___/
 \\\\|///   \\_:_:_:_:_/   \\\\\\|//
 |   _|    |_______|    |   _|
 |   _|   /( ===== )\\   |   _|
 \\\\||//  /\\ `-._.-' /\\  \\\\||//
  (o )  /_ '._____.' _\\  ( o)
 /__/ \\ |    _| |_   _| / \\__\\
 ///\\_/ |_   _| |    _| \\_/\\\\\\
///\\\\_\\ \\    _/ \\    _/ /_//\\\\\\
\\\\|//_/ ///|\\\\\\ ///|\\\\\\ \\_\\\\|//
        \\\\\\|/// \\\\\\|///
        /-  _\\\\ //   _\\
        |   _|| ||-  _|
      ,/\\____|| || ___/\\,
     /|\\___`\\,| |,/'___/|\\
     |||`.\\\\ \\\\ // //,'|||
     \\\\\\\\_//_// \\\\_\\\\_////"
          printer.println(robot)
          printer.feed(3)
          printer.justify(:center)
          printer.println("for @#{photo['user']['nickname']}")
          printer.feed(5)
        rescue
          puts 'no printer attached'
        ensure
        end

      elsif coupon.blank? && photo.present? && photo['id'].to_i > @last_photo['id'].to_i
        puts "no coupons left"
        begin
          sc = SerialConnection.new('/dev/ttyAMA0')
          printer = A2Printer.new(sc)
          printer.begin(200)
          printer.feed(3)
          printer.bold_on
          printer.justify(:center)
          printer.double_width_on
          printer.set_size(:large)
          printer.println("Sorry,")
          printer.println("we are out")
          printer.println("of coupons,")
          printer.println("but take a")
          printer.println(" unicorn.")
          printer.justify(:left)
          printer.feed
          unicorn2 = ' \
  \ji
  /.(((
 (,/"(((__,--.
     \  ) _( /{
     !|| " :||
     !||   :||
     \'\'\'   \'\'\''
          printer.println(unicorn2)
          printer.feed(3)
          printer.double_width_off
          printer.bold_off
          printer.justify(:center)
          printer.println("for @#{photo['user']['nickname']}")
          printer.feed(5)
        rescue
          puts 'no printer attached'
        ensure
        end

      elsif photo.present? && coupon.present? && photo['id'].to_i > @last_photo['id'].to_i
        puts "album updated: #{photo['updated']}"
        #@last_updated = updated
        @last_photo = photo
        puts coupon.inspect
        pp @last_photo
        coupon.username = @last_photo['user']['nickname']
        coupon.user_id = @last_photo['user']['id']
        coupon.photo_id = @last_photo['id']
        coupon.updated = @last_photo['updated']
        puts coupon.inspect
        coupon.save
        puts coupon.errors
        begin
          sc = SerialConnection.new('/dev/ttyAMA0')
          printer = A2Printer.new(sc)

          printer.begin(200)
          printer.feed(3)
          printer.bold_on
          printer.justify(:center)
          printer.double_width_on
          printer.set_size(:large)
          printer.set_line_height(20)
          printer.println(coupon.coupon_provider.name)
          printer.set_size(:medium)
          printer.double_width_off
          printer.println("#{coupon.coupon_provider.url}")
          printer.feed(2)
          printer.set_line_height
          printer.println(coupon.coupon_type)
          printer.println("for @#{coupon.username}")
          printer.double_width_on
          printer.bold_on
          printer.println(coupon.code)
          printer.double_width_off
          printer.bold_off

          #width, height, image = coupon.convert_photo
          #printer.print_bitmap(width, height, image)
          #printer.println(@last_photo['caption'])
          #printer.println("created for )
          #printer.set_size(:small)
          printer.feed
          printer.println("powered by CouponShooter")
          #printer.println("received for @#{coupon.username}")
          #printer.double_width_on
          #printer.bold_off
          #printer.println(@last_photo['caption'])
          #printer.println(@last_photo['webUrl'])
          printer.feed(3)
          coupon.update_attribute(:printed, true)
        rescue
          coupon.update_attribute(:printed, true)
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