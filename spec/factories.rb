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
        FactoryGirl.create(:zone_with_two_organizations,name:zone_admin.name+"_zone_1",zone_admin:zone_admin,des:zone_admin.name+"_desfor_1")
        FactoryGirl.create(:zone_with_two_organizations,name:zone_admin.name+"_zone_2",zone_admin:zone_admin,des:zone_admin.name+"_desfor_2")
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
    contact                     "王科长"
    address                     "xxxxxx"
    phone                       "1482943"
    zone      
    factory :organization_with_a_checker_and_a_worker do
      after_create do |organization|
        FactoryGirl.create(:worker,name:organization.name+"_worker",organization:organization)
        FactoryGirl.create(:checker,name:organization.name+"_checker",organization:organization)
      end
    end
  end

  factory :report do
    sequence(:name)             {|n| "report_template_time_#{n}"}
    reporter_name               "ddssss"
    template
    organization
    committer                   factory: :worker
    status                      "new"
  end


  factory :check_point do
    content                     {Faker::Lorem::sentence(5)}
    check_category  
    can_photo                   false
    can_video                   false
  end
  factory :check_category do
    category                    {Faker::Lorem::words(2)}
    des                         "是否建立了责任制度"
    template        
    factory :check_category_five_check_points do |check_category|
      after_create do |check_category|
        5.times do |n|
          Factory.create(:check_point,check_category:check_category)
        end
      end
    end
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
    factory :template_with_check_valud do |template|
      after_create do |template|
        Factory.create(:check_value,template:template,boolean_name:"检查是否通过",date_name:"整改日期")
      end
    end
    factory :template_with_all_required do |template|
      sequence(:name)  {|n| "template_#{n}"}
      after_create do |template|
        FactoryGirl.create(:check_value,template:template,boolean_name:"检查是否通过",date_name:"整改日期",text_name:"备注" )
        2.times do |n|
          FactoryGirl.create(:check_category_five_check_points,template:template)
        end
      end
    end
  end
  factory :check_value do
    template
    boolean_name                nil
    int_name                    nil
    float_name                  nil
    date_name                   nil
    text_name                   nil
  end

  factory :zone do
    name        "中心区"
    des         "testme for ever"
    zone_admin  
    factory :zone_with_two_organizations do
      after_create do |zone|
       FactoryGirl.create(:organization_with_a_checker_and_a_worker,name:zone.name + "_org_1",zone:zone)
       FactoryGirl.create(:organization_with_a_checker_and_a_worker,name:zone.name + "_org_2",zone:zone)
      end
    end
  end 
end
