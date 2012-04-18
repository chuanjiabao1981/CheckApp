#encoding:utf-8
require 'spec_helper'
require_relative 'user_common_spec'


describe ZoneAdmin do
  let(:the_site_admin) { FactoryGirl.create(:site_admin) }
  before { @user = the_site_admin.zone_admins.build(name:"testme",password:"foobar",password_confirmation:"foobar") }

  subject {@user }

  it { should be_valid }
  it { should respond_to(:name) }
  it { should respond_to(:des)  }
  it { should respond_to(:password)               }
  it { should respond_to(:password_digest)        }
  it { should respond_to(:password_confirmation)  }
  it { should respond_to(:authenticate)           }
  it { should respond_to(:session)      }
  it { should respond_to(:site_admin_id)          }
  it { should respond_to(:site_admin)             }
  it { should respond_to(:templates)              }
  it { should respond_to(:template_max_num)       }
  it { should respond_to(:template_max_video_num) }
  it { should respond_to(:template_max_photo_num) }
  it { should respond_to(:zones)                  }

  user_normal_test

  describe "几个数字项必须为正整数" do
    describe "template max num " do
      before {@user.template_max_num = -1 }
      it { should_not be_valid }
    end
    describe "template_max_video_num " do
      before {@user.template_max_photo_num = -1 }
      it { should_not be_valid }
    end
    describe "template_max_photo_num" do
      before { @user.template_max_video_num = -1 }
      it { should_not be_valid }
    end
  end
  describe "zone_admin删除，相应的zone会被删除" do
    before do
      @user.save
      @zone = @user.zones.create(name:"dddddd",des:"3333333")
    end
    specify do
      Zone.find_by_id(@zone.id).should_not be_nil
      @user.destroy
      Zone.find_by_id(@zone.id).should be_nil
    end
  end
  describe "zone_admin删除,相应的template会被删除" do
    before do
      @user.save
      @user.templates.create(name:"ddddd",for_supervisor:true)
      @user.templates.create(name:"xxxxxx",for_worker:true)
    end
    specify do
      ts = @user.templates
      ts.each do |t|
        Template.find_by_id(t.id).should_not be_nil
      end
      @user.destroy
      ts.each do |t|
        Template.find_by_id(t.id).should be_nil
      end
    end
  end
end
