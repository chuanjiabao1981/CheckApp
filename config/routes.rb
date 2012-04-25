CheckApp::Application.routes.draw do


  resources :sessions, only: [:new, :create, :destroy]

  resources :zone_admins,shallow:true do
    resources :zones,:zone_supervisors,:templates
  end


  resources :zones,shallow:true,only:[] do
    resources :organizations
  end

  resources :organizations,shallow:true,only:[] do
    resources :reports
    #resource  :checker,:worker,except:[:destroy]
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
  match '/site_admin/sessions'   ,to:'sessions#site_admin_create',via: :post
  match '/zone_admin/signin'     ,to:'sessions#zone_admin_new'
  match '/zone_admin/sessions'   ,to:'sessions#zone_admin_create',via: :post
  match '/checker/signin'        ,to:'sessions#checker_new'
  match '/checker/sessions'      ,to:'sessions#checker_create',via: :post

  match '/signout', to: 'sessions#destroy', via: :delete

  root  to:'main#home'


  namespace :api do
    namespace :v1 do
      match '/worker/login',                    to:'sessions#worker_login',via: :post
      match '/zone_supervisor/login',           to:'sessions#zone_supervisor_login',via: :post
      match '/zone_supervisor/zones/:token',    to:'zones#zone_supervisor',via: :get,as:'zone_supervisor_zones'
      match '/worker/zone/',                    to:'zones#worker',via: :get,as:'worker_zone'
    end
  end


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
