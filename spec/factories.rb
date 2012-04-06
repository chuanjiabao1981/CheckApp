# encoding: utf-8
FactoryGirl.define do
  factory :admin  do
    name                        "TestAdmin"
    password                    "foobar"
    password_confirmation       "foobar"
    des                         "来自于山西"
    contact                     "王先生（科长）"
    phone                       "15910666434"
  end

  factory :user do
    name                        "TestName"
    password                    "foobar"
    password_confirmation       "foobar"
    des                         "来自于山西"
    factory :zone_admin do
      zone_admin                true
    end
    factory :site_admin do
      site_admin                true
    end
    factory :supervisor do
      supervisor                true
      admin 
    end
    factory :checker    do
      checker                   true
    end
    factory :worker     do
      worker                    true
    end
  end
end
