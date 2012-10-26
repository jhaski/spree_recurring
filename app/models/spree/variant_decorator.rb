Spree::Variant.class_eval do
  has_many :subscriptions
  attr_accessible :subscribable
end
