class Spree::Admin::SubscriptionsController < Spree::Admin::ResourceController
    def index
      respond_with(@collection) do |format|
        format.html
      end
    end

    def process_s
      sub = Spree::Subscription.find(params[:id])

      new_order = sub.subsequent_orders.build
      new_order.save!
        
      new_order.user        = sub.user
      new_order.bill_address = sub.bill_address
      new_order.ship_address = sub.ship_address
      new_order.email        = sub.user.email
      new_order.save!

      #Add a line item from the variant on this sub and set the price
      new_order.add_variant( sub.variant )
      #NOTE settting quantity as opposed to price becuase during processing payments the order and price will get flipped
      new_order.line_items.first.quantity = sub.price.to_i #doing this will clip a price like 8.8 to 8)
      new_order.line_items.first.price = 1
      new_order.save

      #Process payment for the order
      new_payment = Spree::Payment.new
      new_payment.amount            = new_order.total 
      new_payment.source            = sub.creditcard
      new_payment.payment_method    = sub.gateway

      new_order.payments << new_payment
      new_order.update! #updating totals

      #By setting to confirm we can do new_order.next and we get all the same
      #callbacks as if you were on the order form itself
      new_order.state = 'confirm'
      new_order.next
      new_order.save!

      puts "Order number: #{sub.subsequent_orders.last.number} created"

      sub.renew!
      if new_order.payments.last.state == 'completed'
        sub.reset_declined_count
        puts "Subscription renewed"
      else
        sub.declined
#        SubscriptionsMailer.declined_creditcard_message(sub).deliver
        puts "There was an error proccesing the subscription. Subscription state set to 'error'. Subscription not renewed"
      end
      
      respond_to do |format|
          format.json { render :json => "{}" }
      end
    end

    protected
    
                def collection
                    return @collection if @collection.present?
                    unless request.xhr?
                        @search = Spree::Subscription.ransack(params[:q])
                        @collection = @search.result.page(params[:page]).per(10) #TODO: load from Spree::Config[:admin_subscriptions_per_page]
                    else
                        @collection = Spree::Subscription.ransack(params[:q])
                    end
                end

 
end
