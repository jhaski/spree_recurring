module Spree
  UsersController.class_eval do
    helper 'spree/admin/base'  # for spree_dom_id
    helper 'spree/admin/navigation'
    helper_method :current_user

    prepend_before_filter :load_object, :only => [:cc_update, :cc_edit,:cancel_subscription]
    prepend_before_filter :authorize_actions, :only => [:cc_update,:cc_edit]

    def cancel_subscription
       @user = current_user
       @subscription = Spree::Subscription.where(:user_id => @user).find(params[:id])
    end

    def cc_update
       @user = current_user
       @subscription = Spree::Subscription.where(:user_id => @user).find(params[:id])
       @order = @subscription.parent_order

       if not @order
          payment_id = "1"
       else
          payment_id = @order.payment_method.id.to_s
       end

       gw = @subscription.get_gateway
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

       flash[:notice] = I18n.t(:successfully_updated, :resource => I18n.t(:creditcard))

       redirect_back_or_default(account_path)
    end

    def cc_edit_url
       return "/account/subscriptions/#{params[:id]}/cc"
    end

    def cc_edit
       @user = current_user #TODO: use before filter
       @subscription = Spree::Subscription.where(:user_id => @user).find(params[:id])
       @order = @subscription.parent_order

       if @order.nil?
         @payment_method_id = 1
       else
         @payment_method_id = @order.payment_method.id
       end
       session["user_return_to"] = request.env['HTTP_REFERER']
    end

    private

    def load_subscriptions
      @subscriptions = Spree::Subscription.where(:user_id => @user)
    end
  end
end
