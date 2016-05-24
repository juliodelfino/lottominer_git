Rails.application.routes.draw do

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#index'
  get 'about' => 'welcome#about'
  get 'welcome/ajax_results'
  
  get 'admin' => "admin#index"
  get 'admin/get_db_table'
  get 'admin/ajax_get_results'
  get 'admin/ajax_delete_row'

  get 'task/notify_user_daily'
  get 'task/get_daily_results'

  resources :images
  resources :login do
    collection do
      post 'validate'
      get 'facebook'
      get 'fb_redirect'
    end
  end  
  get '/register' => 'login#register'
  post '/register' => 'login#saveuser'
  get '/verifyemail' => 'login#verify'
  get '/logout' => 'login#logout'
  get '/dashboard' => 'dashboard#index'
  get '/settings' => 'dashboard#settings'
  post '/settings/save' => 'dashboard#save_settings'
  get '/dashboard/get_add_number_form'
  get '/dashboard/get_number_details'
  get '/dashboard/search_number'
  post '/dashboard/ajax_add_number'
  post '/dashboard/ajax_remove_number'
  post '/dashboard/ajax_copy_result_to_user_number'
  
  get '/analytics' => 'analytics#index'
  get '/analytics/game' => 'analytics#game'
  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
