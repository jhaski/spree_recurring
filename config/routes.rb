Spree::Core::Engine.routes.draw do
   
  match '/account/subscriptions/:id/cancel' => 'users#cancel_subscription', :method => 'get'
  match '/account/subscriptions/:id/docancel' => 'users#cancel_subscription_action', :method => 'post'

  match '/account/subscriptions/:id/cc' => 'users#cc_edit', :method => 'get'
  match '/account/subscriptions/:id/updatecc' => 'users#cc_update', :method => 'post'

  namespace :admin do
    resources :subscriptions do
      get 'index'
      member do 
        post 'process_s' 
      end
    end
  end

end
