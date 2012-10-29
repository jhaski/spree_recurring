Spree::Core::Engine.routes.draw do
   
 
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
