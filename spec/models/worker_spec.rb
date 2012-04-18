#encoding:utf-8
require 'spec_helper'
require_relative 'user_common_spec'

describe Worker do
  let(:the_site_admin)      { FactoryGirl.create(:site_admin) }
  let(:a_zone_admin)        { the_site_admin.zone_admins.create(name:"testme",password:"foobar",password_confirmation:"foobar") }
  let(:a_zone)              { a_zone_admin.zones.create(name:"123",des:"3333") }
  let(:a_zone_supervisor)   { a_zone_admin.zone_supervisors.create(name:"222",password:"foobar",password_confirmation:"foobar") }
  let(:a_organiztion)       { FactoryGirl.create(:organization,zone:a_zone)                            }

  before  {@user = FactoryGirl.build(:worker,organization:a_organiztion) }
  subject {@user}
  it { should be_valid }
  it { should respond_to(:organization) }
  it { should respond_to(:reports)      }

  user_normal_test

  describe "普通测试" do
    describe "机构为nil不合法" do
      before { @user.organization = nil }
      it {should_not be_valid}
    end
  end
end
