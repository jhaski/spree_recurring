module Spree
  UsersController.class_eval do
    helper 'spree/admin/base'  # for spree_dom_id
    helper 'spree/admin/navigation'
    helper_method :current_user

    prepend_before_filter :load_object, :only => [:cc_update, :cc_edit]
    prepend_before_filter :authorize_actions, :only => [:cc_update,:cc_edit]

def create_profile(payment)
card = find_card(payment)
address = self.find_address(payment)
email = self.find_email(payment)
if card.gateway_customer_profile_id.nil?
_,profile_id = self.create_customer_profile(card,address,email,"#{Time.now.to_f}")
card.update_attributes(
:gateway_customer_profile_id => profile_id,
:gateway_payment_profile_id => profile_id)
end
end

    def cc_update
       @user = current_user
       @subscription = Spree::Subscription.where(:user_id => @user).find(params[:id])
       @order = @subscription.parent_order

       #flash[:notice] = @order.payment_method.id.to_s + " " + params["payment_source"].to_s

       payment_id = @order.payment_method.id.to_s
       gw = @order.payment_method
       cc = Spree::Creditcard.new(:first_name => params["payment_source"][payment_id]["first_name"],
                                     :last_name => params["payment_source"][payment_id]["last_name"],
                                     :month => params["payment_source"][payment_id]["month"],
                                     :year => params["payment_source"][payment_id]["year"],
                                     :verification_value => params["payment_source"][payment_id]["verification_value"],
                                     :number => params["payment_source"][payment_id]["number"])
       if not cc.valid?
         redirect_to :cc_edit ,:status => :see_other, :flash => { :error => "Card Information Invalid!" }, :id => @subscription.id
         return
       end

       cc.save!

       gw.create_profile(cc)

       @subscription.creditcard = cc

       @subscription.save!

       #if @address.update_attributes(params[:address])
       #flash[:notice] = I18n.t(:successfully_updated, :resource => I18n.t(:creditcard))
       #end

       redirect_back_or_default(account_path)
    end

    def cc_edit_url
       return "/account/subscriptions/#{params[:id]}/cc"
    end

    def cc_edit
       @user = current_user #TODO: use before filter
       @subscription = Spree::Subscription.where(:user_id => @user).find(params[:id])
       @order = @subscription.parent_order
       session["user_return_to"] = request.env['HTTP_REFERER']
    end

    private

    def load_subscriptions
      @subscriptions = Spree::Subscription.where(:user_id => @user)
    end
  end
end
