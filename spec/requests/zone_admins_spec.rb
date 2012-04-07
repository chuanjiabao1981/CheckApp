#encoding: utf-8
require 'spec_helper'

describe "ZoneAdmins" do
  subject { page }
  let(:the_site_admin) { FactoryGirl.create(:site_admin,name:'t_s_admin') }
  let(:a_zone_admin)   { FactoryGirl.create(:zone_admin,name:'a_z_admin',admin:the_site_admin) }
  describe "新增zoneadmin" do
    describe "未登录用户访问 Get" do
      before { get new_zone_admins_path }
      specify { response.should redirect_to(root_path ) }
    end
    describe "未登录用户访问Post" do
      before {post zone_admins_path }
      specify { response.should redirect_to(root_path) }
    end
    describe "登陆的zone_admin" do
      before { get new_zone_admins_path }
      specify { response.should redirect_to(root_path) }
    end
    describe "登陆的site_admin" do
      before do
        sign_in the_site_admin
        visit new_zone_admins_path  ##这里要改成click
      end
      describe "正常访问" do
        it { should have_content("新增zone管理员") }
        it {should have_link('zone管理员')}
        it {should have_link('模板管理')  }
        it {should have_link('设置')      }
        it {should have_link('退出',href:signout_path)}
        it {should_not have_link('登陆',href:signin_path)}
      end
      describe "不合法信息" do
        it "不增加用户" do
          expect { click_button "确定"}.not_to change(User,:count)
        end
      end
      describe "合法信息" do
        before do
          fill_in "账号" ,    with: "test_z_admin"
          fill_in "密码",     with: "foobar"
          fill_in "确认密码", with: "foobar"
          fill_in "备注",     with: "没啥可说的"
        end
        it " 增加一个用户" do
          expect { click_button "确定"}.to change(User,:count).by(1)
          a = User.find_by_name("test_z_admin")
          a.should be_zone_admin
        end
      end
    end
  end
end
