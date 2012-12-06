Spree::Variant.class_eval do
  has_and_belongs_to_many :subscriptions, :join_table => "spree_additional_subscription_variants"
  attr_accessible :subscribable
end
