class Spree::Subscription < ActiveRecord::Base

  def self.create_from_order(order,line_item)
    # get subscription info TODO: load from product configuration.
    interval = "month"
    duration = 1

    s = Spree::Subscription.create(:interval => interval,
                        :duration => duration,
                        :user => order.user,
                        :variant => line_item.variant,
                        :price => line_item.price,
                        :next_payment_at => Time.now + eval(duration.to_s + "." + interval.to_s),
                        :creditcard => order.creditcards[0],
                        :created_by_order_id => order.id,
                        :gateway => order.payment_method)

    return s
  end

  def get_gateway
    return self.gateway if not self.gateway.nil?
    return self.parent_order.payment_method if not self.parent_order.nil?
  end

  attr_accessible :user,:variant,:creditcard,:parent_order,:ship_address,:bill_address,:expiry_notifications,:price,:state
  attr_accessible :interval, :duration, :next_payment_at, :created_by_order_id,:gateway

  belongs_to :user
  belongs_to :variant
  belongs_to :creditcard
  belongs_to :gateway

  belongs_to :parent_order, :class_name => "Spree::Order", :foreign_key => :created_by_order_id

  belongs_to :ship_address, :foreign_key => :shipping_address_id
  belongs_to :bill_address, :foreign_key => :billing_address_id

  has_many :expiry_notifications

  has_many :subsequent_orders, :class_name => "Spree::Order", :foreign_key => :created_by_subscription_id

  accepts_nested_attributes_for :creditcard

  validates :price, :presence => true, :numericality => true
  validate :check_whole_dollar_amount

  state_machine :state, :initial => :active do

    event :cancel do
      transition :to => :canceled, :if => :allow_cancel?
    end

    event :expire do
      transition :to => :expired
    end

    event :reactivate do
      transition :to => :active, :from => [:expired, :error, :declined]
    end

    event :renew do
      transition :active => same
    end

    event :declined do
      transition :active => :error, :if => :third_decline?
      transition :active =>  same
    end
 
    after_transition :on => :renew, :do => [:on_renew,:reset_declined_count]
    before_transition :on => :reactivate, :do => :reset_declined_count
    before_transition :on => :declined, :do => :bump_up_declined_count
  end

  scope :backlog, lambda{{:conditions => ["next_payment_at <= ? ", Time.now] }}
  scope :active, lambda{{:conditions => {:state => "active"}}}


  def allow_cancel?
    self.state != 'canceled'
  end

  def inactive?
    self.state != 'active'
  end

  def check_whole_dollar_amount
    # why does this need to be true?
    errors.add(:price,"should be a whole dollar amount") if self.price.to_i != self.price
  end

  def due_on
    next_payment_at
  end

  def due_soon?
    next_payment_at < Time.now + 1.week
  end

  def on_renew
      self.update_attribute(:next_payment_at, next_payment_at + eval(self.duration.to_s + "." + self.interval.to_s))
  end


  def backlogged?
    self.next_payment_at <= Time.now ? true : false
  end

  def reset_declined_count
    self.update_attribute(:declined_count , 0)
  end

  def third_decline?
    self.declined_count >= 2
  end

  def subscription_bill_address
    self.billing_address || self.parent_order.bill_address
  end

  def subscription_ship_address
    self.ship_address || self.parent_order.ship_address
  end

  def latest_subsequent_order
    self.subsequent_orders.order('created_at DESC').first
  end

  def bump_up_declined_count
    self.declined_count += 1
  end


  def available_payment_methods
    @available_payment_methods ||= Spree::PaymentMethod.available(:front_end)
  end

    def payment_method
#      if payment and payment.payment_method
#        payment.payment_method
#      else
        available_payment_methods.first
#      end
    end

end
