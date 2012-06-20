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
    template_max_photo_num      100
    template_max_num            100
    template_max_video_num      100
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
  
  factory :report_record do
    report
    check_category  
    check_point
    video_path      "1.jpg"
    boolean_value   {rand(2) == 1}
    float_value     {rand(1000.0)}
    int_value       {rand(2000)}
    date_value      {rand(10.years).ago.strftime("%Y-%m-%d")  }
    text_value      {Faker::Lorem::sentence(20)}
    photo_path      { check_point.can_photo ? File.open(File.join(Rails.root, 'spec', 'support', 'report_record', 'photo', 'test.jpg')):nil }
    factory :report_record_with_photo do
      photo_path    {File.open(File.join(Rails.root, 'spec', 'support', 'report_record', 'photo', 'test.jpg')) }
    end
    factory :report_record_with_9m_photo do
      photo_path    {File.open(File.join(Rails.root, 'spec', 'support', 'report_record', 'photo', '9m.jpg')) }
    end
  end

  factory :report do
    #sequence(:name)             {|n| "report_template_time_#{n}"}
    reporter_name               "ddssss"
    template
    organization
    committer                   factory: :worker
    status                      "new"
    factory :report_with_some_records do
      after_create do |report|
        report.template.check_categories.first.check_points.each do |cp|
          Factory.create(:report_record,report:report,check_category:cp.check_category,check_point:cp)
        end
        n = 0
        print report.template.zone_admin.template_max_photo_num
        report.template.check_categories[2].check_points.each do |cp|
          Factory.create(:report_record,report:report,check_category:cp.check_category,check_point:cp) 
          n = n+1
          break if n == 4 
        end
      end
    end
    factory :report_with_all_records do
      after_create do |report| 
        report.template.check_categories.each do |cc|
          cc.check_points.each do |cp|
            Factory.create(:report_record,report:report,check_category:cp.check_category,check_point:cp)
          end
        end
      end
    end
  end


  factory :check_point do
    content                     {Faker::Lorem::sentence(5)}
    check_category  
    can_photo                   { rand(2) == 1}
    can_video                   false
    Rails.logger.debug("Factory:create a check point")
  end
  factory :check_category do
    category                    {Faker::Lorem::sentence(1)}
    des                         "是否建立了责任制度"
    template        
    factory :check_category_five_check_points do |check_category|
      after_create do |check_category|
        check_category.reload
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
        template.zone_admin.reload
        Factory.create(:check_value,template:template,boolean_name:"检查是否通过",date_name:"整改日期",float_name:"检查值",int_name:"设备温度",text_name:"备注")
      end
    end
    factory :template_with_all_required do |template|
      sequence(:name)  {|n| "template_#{n}"}
      after_create do |template|
        template.zone_admin.reload
        FactoryGirl.create(:check_value,template:template,boolean_name:"检查是否通过",date_name:"整改日期",text_name:"备注",float_name:"检查值",int_name:"设备高度")
        3.times do |n|
          FactoryGirl.create(:check_category_five_check_points,template:template)
        end
        Rails.logger.debug("Factory:template categoty num:#{template.check_categories.size}")
      end
    end
    factory :template_with_3_normal_category_1_zero_check_point_category do |template|
      sequence(:name)  {|n| "template_un_#{n}"}
      after_create do |template|
        template.zone_admin.reload
        FactoryGirl.create(:check_value,template:template,boolean_name:"检查是否通过",date_name:"整改日期",text_name:"备注",float_name:"检查值",int_name:"设备高度")
        3.times do |n|
          FactoryGirl.create(:check_category_five_check_points,template:template)
        end
        Factory.create(:check_category,template:template)
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
