#encoding: utf-8
require 'spec_helper'

describe "ZoneAdmins" do
  subject { page }
  let!(:the_site_admin) { FactoryGirl.create(:site_admin,name:'t_s_admin') }
  let!(:a_zone_admin)   { FactoryGirl.create(:zone_admin,name:'a_z_admin',site_admin:the_site_admin) }
  let!(:b_zone_admin)   { FactoryGirl.create(:zone_admin,name:'b_z_admin',site_admin:the_site_admin) }
  let!(:a_org_checker)  { FactoryGirl.create(:checker,name:'a_checker') }
  describe "新增zoneadmin" do
    describe "未登录用户访问 Get" do
      before { get new_zone_admin_path }
      specify { response.should redirect_to(root_path ) }
    end
    describe "未登录用户访问Post" do
      before {post zone_admins_path }
      specify { response.should redirect_to(root_path) }
    end
    describe "登陆的zone_admin" do
      before do
       sign_in a_zone_admin
       get new_zone_admin_path 
      end
      specify { response.should redirect_to(root_path) }
    end
    describe "登陆的site_admin" do
      before do
        sign_in the_site_admin
        visit new_zone_admin_path  ##这里要改成click
      end
      describe "正常访问" do
        it { should have_content("新增zone管理员") }
        check_site_admin_left
      end
      describe "不合法信息" do
        it "不增加用户" do
          expect { click_button "确定"}.not_to change(ZoneAdmin,:count) 
          page.should have_content('表单有3个错误')
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
          expect { click_button "确定"}.to change(ZoneAdmin,:count).by(1)
          a = ZoneAdmin.find_by_name("test_z_admin")
          a.should_not be_nil
        end
      end
    end
  end
  describe "编辑已有zoneadmin" do
    describe "非登陆用户GET" do
      before  { get edit_zone_admin_path(a_zone_admin) }
      specify {response.should redirect_to(root_path) }
    end
    describe "非登陆用户Put" do
      before { put zone_admin_path(a_zone_admin) }
      specify { response.should redirect_to(root_path) }
    end
    describe "登陆的zone_admin" do
      before do
        sign_in a_zone_admin
        put zone_admin_path(a_zone_admin)
      end
      specify { response.should redirect_to(root_path) }
    end
    describe "编辑一个不存在的用户" do
      before do 
        sign_in the_site_admin
        get edit_zone_admin_path(201233) 
      end
      specify { response.should redirect_to(root_path) }
    end
    describe "登陆的site_admin" do
      before do
        sign_in the_site_admin
        visit edit_zone_admin_path(a_zone_admin)
      end
      describe "正常访问" do
        it { should have_content(a_zone_admin.name) }
        check_site_admin_left
      end
      describe "提供非法信息" do
        before do
          fill_in '密码' ,with: '1234' 
          click_button '保存'
        end
        it { should have_content('错误') }
      end
      describe "正常更新不含密码" do
        let(:new_name) {"test_new"}
        let(:new_des)  {"test_new des for test你好"}
        before do
          fill_in '账号', with: new_name
          fill_in '备注', with: new_des
          click_button '保存'
        end
        specify { a_zone_admin.reload.name.should == new_name }
        specify { a_zone_admin.reload.des.should == new_des  }
        it { should have_selector('td',text:new_name)}
      end
      describe "正常更新 密码" do
        let(:new_password) { "password_new"}
        before do
          fill_in '密码', with:new_password
          fill_in '确认密码',with:new_password
          click_button '保存'
          delete signout_path
        end
        describe "旧密码登陆" do
          before { sign_in a_zone_admin }
          it { should have_selector('div.alert.alert-error', text: '账号或密码错误')}
        end
      end
    end
  end

  describe "浏览一个site_admin" do
    describe "未登录用户" do
      before { get zone_admin_path(a_zone_admin) }
      specify { response.should redirect_to (root_path) }
    end
    describe "登陆的非site_admin用户" do
      before do
        sign_in a_zone_admin
        get zone_admin_path(a_zone_admin)
      end
      specify { response.should redirect_to (root_path) }
    end
    describe "登陆的site_admin" do
      before { sign_in the_site_admin }
      describe "访问一个不存在的zone_admin" do
        before { get zone_admin_path(1203) }
        specify { response.should redirect_to(root_path) }
      end
      describe "访问一个存在的zone_admin" do
        before { visit zone_admin_path(a_zone_admin) }
        it     { should have_selector("td",:text=>a_zone_admin.name) }
        it     { should have_selector("td",:text=>a_zone_admin.des)}
        check_site_admin_left
      end
    end
  end
  describe "浏览全部的zone_admin" do
    describe "未登录用户" do
      before { get zone_admins_path } 
      specify { response.should redirect_to(root_path) }
    end
    describe "登陆的非site_admin" do
      before do 
        sign_in a_zone_admin
        get zone_admins_path 
      end
      specify { response.should redirect_to(root_path) }
    end
    describe "登陆site_admin" do
      before do
        sign_in the_site_admin
        visit zone_admins_path
      end
      it { should have_link('新增',href:new_zone_admin_path)}
      it { should have_selector('td',link:zone_admin_path(a_zone_admin)) }
      it { should have_selector('td',text:a_zone_admin.des)}
      it { should have_link(b_zone_admin.name,href:zone_admin_path(b_zone_admin))}
      it { should_not have_selector('a',text:the_site_admin.name)}
      it { should_not have_selector('a',text:a_org_checker.name) }
      it { should have_link('编辑',href:edit_zone_admin_path(a_zone_admin))}
      it { should have_link('编辑',href:edit_zone_admin_path(b_zone_admin))}
      it { should have_link('删除',href:zone_admin_path(a_zone_admin))}
      it { should have_link('删除',href:zone_admin_path(b_zone_admin))}
      check_site_admin_left
    end
  end
  describe "删除zone_admin" do
    describe "未登录用户" do
      before { delete zone_admin_path(a_zone_admin) }
      specify{ response.should redirect_to(root_path)}
    end
    describe "非site_admin登陆用户" do
      before do
        sign_in(b_zone_admin)
        before { delete zone_admin_path(b_zone_admin) }
        specify{ response.should redirect_to(root_path)}
      end
    end
    describe "登陆的site_admin" do
      before do
        sign_in(the_site_admin)
      end
      describe "删除成功" do
        before do
          visit zone_admins_path
        end
        it "删除成功" do
          expect { click_link('删除')}.to change(ZoneAdmin,:count).by(-1)
          page.should_not have_link('删除',href:zone_admin_path(a_zone_admin))
          page.should     have_link('删除',href:zone_admin_path(b_zone_admin))
        end
      end
    end
  end
end
