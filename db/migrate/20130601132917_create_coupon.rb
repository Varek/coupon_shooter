class CreateCoupon < ActiveRecord::Migration
  def up
    create_table :coupons do |t|
      t.string :coupon_provider_id
      t.string :code
      t.string :coupon_type
      t.integer :photo_id
      t.integer :user_id
      t.string :username
      t.boolean :printed
    end
  end

  def down
    drop_table :coupons
  end
end
