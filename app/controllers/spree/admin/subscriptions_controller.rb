class Spree::Admin::SubscriptionsController < Spree::Admin::ResourceController
  def index
    respond_with(@collection) do |format|
      format.html
    end
  end

  def process_s
    sub = Spree::Subscription.find(params[:id])
    sub.renew!
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
