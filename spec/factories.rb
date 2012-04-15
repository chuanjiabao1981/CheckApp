# encoding: utf-8
FactoryGirl.define do
  factory :site_admin do
    name                        "TestAdmin"
    password                    "foobar"
    password_confirmation       "foobar"
  end
  factory :zone_admin do
    name                        "TestZoneAdmin"
    password                    "foobar"
    password_confirmation       "foobar"
    site_admin

  end

  factory :check_point do
    content                     "是否有执照"
    check_category  
    can_photo                   false
    can_video                   false
  end
  factory :check_category do
    category                    "手续责任"
    des                         "是否建立了责任制度"
    template        
  end
  factory :template do
    name                        "食品安全2012"
    zone_admin
    factory :for_worker do
      for_worker                true
    end
    factory :for_supervisor do
      for_supervisor            true
    end
  end
  factory :check_value do
    template
    boolean_name                nil
    int_name                    nil
    float_name                  nil
    date_name                   nil
  end
 
  factory :zone do
    name        "中心区"
    des         "testme for ever"
    zone_admin  
  end 

  factory :user do
    name                        "TestName"
    password                    "foobar"
    password_confirmation       "foobar"
    des                         "来自于山西"
    factory :_zone_admin do
      zone_admin                true
    end
    factory :_site_admin do
      site_admin                true
    end
    factory :supervisor do
      zone_supervisor           true
      admin 
    end
    factory :checker    do
      org_checker               true
    end
    factory :worker     do
      org_worker                 true
    end
  end
end
