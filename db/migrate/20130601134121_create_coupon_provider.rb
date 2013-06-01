class CreateCouponProvider < ActiveRecord::Migration
  def up
    create_table :coupon_providers do |t|
      t.string :name
      t.string :url
    end
  end

  def down
    drop_table :coupon_providers
  end
end
