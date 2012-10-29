module Spree
  UsersController.class_eval do
    helper 'spree/admin/base'  # for spree_dom_id
    helper 'spree/admin/navigation'

    before_filter :load_subscriptions, :only => :show

    private

    def load_subscriptions 
      @subscriptions = Spree::Subscription.where(:user_id => @user)
    end
  end
end
