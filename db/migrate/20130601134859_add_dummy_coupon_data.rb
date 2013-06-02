class AddDummyCouponData < ActiveRecord::Migration
  def up
    @cp = CouponProvider.create(:name => 'Foobar', :url => 'foobar.com')
    coupon_code = SecureRandom.hex.to_s[0..5]
    Coupon.create(:coupon_provider_id => @cp.id, :code => coupon_code, :coupon_type => "#{SecureRandom.random_number(14)+1}% discount", photo_id: 13873789, username: 'spiegeleule', user_id: 160004, printed: true, updated:"2013-06-02T12:29:46+0200")
    coupon_code = SecureRandom.hex.to_s[0..5]
    Coupon.create(:coupon_provider_id => @cp.id, :code => coupon_code, :coupon_type => "#{SecureRandom.random_number(14)+1}% discount")
    # 10.times do |i|
    #   begin
    #     coupon_code = SecureRandom.hex.to_s[0..5]
    #   end while Coupon.where(:coupon_provider_id => @cp.id, :code =>coupon_code).present?
    #   Coupon.create(:coupon_provider_id => @cp.id, :code => coupon_code, :coupon_type => "#{SecureRandom.random_number(14)+1}% discount")
    # end
  end

  def down
  end
end
