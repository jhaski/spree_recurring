Spree::Order.class_eval do
  has_many :spree_subscriptions, :foreign_key => :created_by_order_id
  
  belongs_to :parent_subscription, :foreign_key => :created_by_subscription_id, :class_name => "Spree::Subscription"

  def contains_subscription?
    line_items.any? { |line_item| line_item.variant.subscribable? }
  end

  def created_by_subscription?
    self.parent_subscription.present?
  end

  state_machine.after_transition :to => 'complete' do |order|
    # only create a subscription of the order being completed isn't already attached to a subscription.
    if order.parent_subscription.nil?
      order.create_subscriptions
    end
  end
    
  def create_subscriptions
    order = self
    order.line_items.map do |line_item|
      if line_item.creates_subscription?
        subscription = Spree::Subscription.create_from_order(order,line_item)
      end
    end
  end
end
