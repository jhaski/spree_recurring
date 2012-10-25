class CreateExpiryNotifications < ActiveRecord::Migration
  def up
    create_table :spree_expiry_notifications do |t|
      t.references :subscription
      t.interer :interval
      t.timestamps
    end
  end

  def down
    drop_table :spree_expiry_notifications
  end
end
