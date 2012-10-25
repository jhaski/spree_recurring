class CreateSubscriptions < ActiveRecord::Migration
  def up
    create_table :spree_subscriptions do |t|
      t.datetime :next_payment_at
      t.integer :duration
      t.string :interval
      t.string :state
      t.references :user
      t.references :variant
      t.references :creditcard

      t.integer :declined_count, :default => 0
      t.integer :created_by_order_id
      t.integer :billing_address_id 
      t.integer :shipping_address_id
    
      t.float :price 

      t.timestamps
    end
  end

  def down
    drop_table :subscriptions
  end
end
