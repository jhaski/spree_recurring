class AddAdditionalVariantsToSpreeSubscription < ActiveRecord::Migration
  def change
    create_table :spree_additional_subscription_variants, :id => false do |t|
      t.integer :variant_id
      t.integer :subscription_id
    end
  end
end
