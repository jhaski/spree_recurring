class AddGatewayToSubscription < ActiveRecord::Migration
  def change
    add_column :spree_subscriptions, :gateway_id, :integer
  end
end
