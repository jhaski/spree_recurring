class CreateSpreeCancellationData < ActiveRecord::Migration
  def change
    create_table :spree_cancellation_data do |t|
      t.references :subscription
      t.text :reasons
      t.text :comments

      t.timestamps
    end
    add_index :spree_cancellation_data, :subscription_id
  end
end
