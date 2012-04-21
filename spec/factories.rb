# encoding: utf-8
FactoryGirl.define do
  factory :site_admin do
    name                        "TestAdmin"
    password                    "foobar"
    password_confirmation       "foobar"

    factory :site_admin_with_two_zone_admin do
      after_create do |site_admin|
        FactoryGirl.create(:zone_admin_with_two_zone,site_admin:site_admin,name:"a_zone_admin")
        FactoryGirl.create(:zone_admin_with_two_zone,site_admin:site_admin,name:"b_zone_admin")
      end
    end
  end

  factory :zone_admin do
    name                        "TestZoneAdmin"
    password                    "foobar"
    password_confirmation       "foobar"
    site_admin
    factory :zone_admin_with_two_zone do
      after_create do |zone_admin|
        FactoryGirl.create(:zone,name:zone_admin.name+"_zone_1",zone_admin:zone_admin,des:zone_admin.name+"_desfor_1")
        FactoryGirl.create(:zone,name:zone_admin.name+"_zone_2",zone_admin:zone_admin,des:zone_admin.name+"_desfor_2")
        FactoryGirl.create(:zone_supervisor,name:zone_admin.name+"_supervisor_1",zone_admin:zone_admin)
        FactoryGirl.create(:zone_supervisor,name:zone_admin.name+"_supervisor_2",zone_admin:zone_admin)
      end
    end
  end
  factory :zone_supervisor do
    name                        "TestZoneSupervisor"
    password                    "foobar"
    password_confirmation       "foobar"
    zone_admin
  end
  factory :worker do
    name                        "TestWorker"
    password                    "foobar"
    password_confirmation       "foobar"
    organization        
  end

  factory :checker do
    name                        "TestChecker"
    password                    "foobar"
    password_confirmation       "foobar"
    organization
  end
  factory :organization do
    name                        "11122"
    phone                       "eeeeddd"
    contact                     "王科长"
    address                     "xxxxxx"
    zone      
  end

  factory :report do
    name                        "template_name_time"
    reporter_name               "ddssss"
    template
    organization
    status                      "new"
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
  factory :template do |t|
    t.name                        "食品安全2012"
    zone_admin
    factory :for_worker do
      t.for_worker                true
    end
    factory :for_supervisor do
      t.for_supervisor            true
    end
    factory :template_with_check_valud do |template|
      after_create do |template|
        Factory.create(:check_value,template:template,boolean_name:"检查是否通过",date_name:"整改日期")
      end
    end
  end
  factory :check_value do
    template
    boolean_name                nil
    int_name                    nil
    float_name                  nil
    date_name                   nil
  end

  factory :template_with_check_value,parent: :template do
    after_create { |a| Factory(:check_value, :template => a) }
  end
 
  factory :zone do
    name        "中心区"
    des         "testme for ever"
    zone_admin  
  end 
end
