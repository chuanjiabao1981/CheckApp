CheckApp::Application.routes.draw do

  resources :sessions, only: [:new, :create, :destroy]

  resources :zone_admins,shallow:true do
    resources :zones,:zone_supervisors,:templates
  end


  resources :zones,shallow:true,only:[] do
    resources :organizes
  end

  resources :organizes,shallow:true,only:[] do
    resources :reports
  end

  resources :reports,shallow:true,only:[] do
    resources :records
  end 

  resources :templates  ,:shallow => true,only:[] do 
    resources :check_categories do
      resources :check_points ,:except => :show
    end
  end


  match '/site_admin/signin'     ,to:'sessions#site_admin_new'
  match '/site_admin/sessions'  ,to:'sessions#site_admin_create',via: :post

  match '/signin',  to: 'sessions#new'
  match '/signout', to: 'sessions#destroy', via: :delete

  root  to:'main#home'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
