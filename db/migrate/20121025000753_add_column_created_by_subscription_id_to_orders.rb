class AddColumnCreatedBySubscriptionIdToOrders < ActiveRecord::Migration
  def change
    add_column :spree_orders, :created_by_subscription_id, :integer, :references => :spree_subscriptions
  end
end
