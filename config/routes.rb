#encoding:utf-8
CheckApp::Application.routes.draw do


  resources :sessions, only: [:new, :create, :destroy]

  resources :zone_admins,shallow:true do
    resources :zones,:zone_supervisors,:templates
  end


  resources :zones,shallow:true,only:[] do
    resources :organizations
  end

  resources :organizations,shallow:true,only:[] do
    resources :reports,shallow:true,except:[:show] do
      collection do
        #  督察报告，格式html,mobile
        get 'zone_supervisor',action:'supervisor_report'
        #  自查报告，格式html，mobile
        get 'worker',action:'worker_report'
      end
      member do
        #展示报告检查类型(替换了resource是的show)
        get 'check_categories',defaults:{format:'mobile'}
        #展示报告检查类型下的检查点
        get 'check_category/:check_category_id/check_points',defaults:{format:'mobile'},as:'check_category_check_point_reports',action:'check_points'
        #把报告的内容一次性展示出来，主要对zone_admin和checker使用,格式仅html
        get 'report_detail'
        #
        put 'pass'
        put 'reject' 
      end
    end
  end

  match '/report/:id/check_point/:check_point_id/records/new',
        to:'report_records#new_report_record',
        defaults:{format:'mobile'},
        via: :get,
        as:'new_report_record'
  match '/report/:id/check_point/:check_point_id/records/create',
        to:'report_records#create_report_record',
        defaults:{format:'mobile'},
        via: :post,
        as:'create_report_record'
  resources :report_records,only:[:edit,:update,:show,:destroy]
  
  

  resources :templates  ,:shallow => true,only:[] do 
    resources :check_categories do
      resources :check_points ,:except => :show
    end
  end


  match '/site_admin/signin'              ,to:'sessions#site_admin_new'
  match '/site_admin/sessions'            ,to:'sessions#site_admin_create',via: :post
  match '/zone_admin/signin'              ,to:'sessions#zone_admin_new'
  match '/zone_admin/sessions'            ,to:'sessions#zone_admin_create',via: :post
  match '/checker/signin'                 ,to:'sessions#checker_new'
  match '/checker/sessions'               ,to:'sessions#checker_create',via: :post
  match '/worker/signin'                  ,to:'sessions#worker_new',format:'mobile'
  match '/worker/sessions'                ,to:'sessions#worker_create',via: :post,format:'mobile'
  match '/zone_supervisor/signin'         ,to:'sessions#zone_supervisor_new',format:'mobile'
  match '/zone_supervisor/sessions'       ,to:'sessions#zone_supervisor_create',via: :post,format:'mobile'


  match '/signout'                        ,to:'sessions#destroy', via: :delete
  match '/zone_supervisor_home'           ,to:'main#zone_supervisor_home',via: :get,format:'mobile'
  match '/zone_admin_home/:zone_admin_id' ,to:'main#zone_admin_home',via: :get,as:'zone_admin_home'
  match '/checker_home/:checker_id'       ,to:'main#checker_home',via: :get,as:'checker_home'
  match '/setting'                        ,to:'user_settings#setting',via: :get,as:'user_setting'
  match '/setting_update'                 ,to:'user_settings#setting_update',via: :put, as:'user_setting_update'
  match '/about'                          ,to:'main#about'  ,via: :get,as:'about'
  match '/help'                           ,to:'main#help'   ,via: :get,as:'help'
  match '/contact'                        ,to:'main#contact',via: :get,as:'contact'
  root  to:'main#home'

  resources :zone_supervisors,shallow:true,only:[] do
    resources :zones,only:[:index]
  end


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
