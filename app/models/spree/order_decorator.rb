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
    order.create_subscription?
  end

  private
    
    def create_subscription?
      order = self

      order.line_items.map do |line_item|
      
        if (line_item.variant.is_master? && line_item.variant.product.subscribable?) || 
           (!line_item.variant.is_master? && line_item.variant.subscribable?)


          # get subscription info TODO: load from product configuration.
          interval = "month"
          duration = 1  

          # create
          subscription = Subscription.create(:interval => interval,
                                             :duration => duration,
                                             :user => order.user,
                                             :variant => line_item.variant,
                                             :price => line_item.price,
                                             :next_payment_at => Time.now + eval(duration.to_s + "." + interval.to_s),
                                             :creditcard => order.creditcards[0],
                                             :created_by_order_id => order.id)
          return true    
        end
        return false
      end.reduce(0) { |x,i| x ? i+1 : i } # get the subscription count
    end
end
