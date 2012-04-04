# encoding: utf-8

require 'spec_helper'

describe User do
  ##注意这里只能用build create会直接写入db的
  before  { @user = FactoryGirl.build(:user) }
  subject { @user }

  it { should respond_to(:name)                   }
  it { should respond_to(:des)                    }
  it { should respond_to(:password)               }
  it { should respond_to(:password_digest)        }
  it { should respond_to(:password_confirmation)  }
  it { should respond_to(:authenticate)           }
  it { should respond_to(:site_admin)             }
  it { should respond_to(:zone_admin)             }
  it { should respond_to(:supervisor)             }
  it { should respond_to(:worker)                 }
  it { should respond_to(:checker)                }
  it { should respond_to(:admin_id)               }

  it { should be_valid}
  it { should_not be_site_admin                   }
  it { should_not be_zone_admin                   }
  it { should_not be_supervisor                   }
  it { should_not be_worker                       }
  it { should_not be_checker                      }


  describe "通用测试" do
    describe "空用户名不合法" do
      before { @user.name = " " }
      it { should_not be_valid }
    end
    describe "用户名过长" do
      before  { @user.name = "t"*100 }
      it { should_not be_valid }
    end

    describe "用户包含不合法字符" do
      it "都不合法" do
        invalid_name = ["a#","a b","%%"]
        invalid_name.each do |invalid|
          @user.name = invalid
          @user.should_not be_valid
        end
      end
    end
    describe "用户描述过长" do
      before {@user.des = "asdf"*10000 }
      it {should_not be_valid }
    end

    describe "合法用户名称" do
      it "全部合法" do
        valid_name = ["abc","a_b","a1123_dd"]
        valid_name.each do |valid|
          @user.name = valid
          @user.should be_valid
        end
      end
    end
    describe "重复用户名" do
      before do 
        @dup_user = @user.dup
        @dup_user.save
      end
      it {  should_not be_valid }
    end
    describe "密码相关测试" do
      describe "密码为空不合法" do
        before { @user.password = @user.password_confirmation = " " }
        it {should_not be_valid}
      end
      describe "密码不匹配不合法" do
        before {@user.password_confirmation ="mis match"}
        it {should_not be_valid}
      end
      describe "确认密码为nil不合发" do
        before {@user.password_confirmation = nil }
        it {should_not be_valid }
      end
    end
  end
  describe "supervisor 测试" do
    before do 
      @admin = FactoryGirl.create(:zone_admin,name:"test_admin")
      @user  = @admin.supervisors.build(name:"sp1",password:"foobar",password_confirmation:"foobar")
      @user.supervisor = true
    end

    it {should be_supervisor}
    it {should be_valid}
    specify {
        @user.errors.each do |n|
          puts @user.errors[n]
        end
       }

    describe "没有admin_id 的是不合法的" do
      before { @user.admin_id = nil}
      it {should_not be_valid }
    end

    describe "对应的admin_id的用户必须是zone_admin" do
        let(:admin_of_user) { @user.admin }
        specify {admin_of_user.should be_zone_admin}
    end

    describe "非zone_admin创建的supervisor不合法" do
      before {@admin.zone_admin = false} 
      it { should_not be_valid }
    end

  end
end
