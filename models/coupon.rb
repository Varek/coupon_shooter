class Coupon < ActiveRecord::Base

  belongs_to :coupon_provider

  def self.tmp_path=(path)
      @tmp_path = path
    end
    def self.tmp_path
      @tmp_path
    end

  def convert_photo
    photo = EyeEmConnector.photo(self.photo_id)['photo']
    pp photo
    file_name = photo['thumbUrl'].split('/').last
    puts file_name
    thumb_url = "http://cdn.eyeem.com/thumb/256/256/#{file_name}"
    puts thumb_url
    #tmp_path = "#{settings.root}/tmp"
    uri = URI.parse(thumb_url)
    Net::HTTP.start(uri.host) do |http|

      #if http.request_head(uri.host).is_a? Net::HTTPOK
        puts "Downloading #{file_name}.jpg "
        resp = http.get(uri.path)
        pf = File.open(File.join(Coupon.tmp_path,"#{file_name}.jpg"), 'wb')
        pf.write(resp.body)
        pf.close
      #else
      #  puts "Failed to download"
      #end
    end
    path = File.join(Coupon.tmp_path,"#{file_name}.jpg")
    converted_path = File.join(Coupon.tmp_path,"#{file_name}.bmp")
    `convert -colorspace Gray -ordered-dither o2x2 #{path} #{converted_path}`
    img = ImageList.new("#{converted_path}")[0]
    bits = []
    white = 65535
    limit = white / 2
    img.each_pixel { |pixel, _, _| bits << ((pixel.intensity < limit) ? 1 : 0) }
    bytes = []
    bits.each_slice(8) { |s| bytes << ("0" + s.join).to_i(2)}
    width = img.columns
    height = img.rows

    return width, height, bytes

  end

end