Spree::Core::Engine.routes.draw do


  namespace :admin do
    resources :subscriptions do
      get 'index'
      member do 
        post 'process_s' 
      end
    end
  end

end
