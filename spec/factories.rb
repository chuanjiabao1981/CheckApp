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
  end
end
