#encoding: utf-8
require 'spec_helper'

describe "StaticPages" do

  subject { page }

  describe "非登陆用户" do
    before { visit root_path }
    it { should have_link('登陆',href:signin_path) }
    it { should_not have_link('退出',href:signout_path) }
    it { should_not have_link('zone管理员') }
    it { should_not have_link('模板管理')  }
    it { should_not have_link('督察员')}
    it { should have_content('首页')}
  end

  describe "SiteAdmin的首页" do

    describe "登陆用户" do
      let(:siteadmin) { FactoryGirl.create(:site_admin) }
      before do 
        visit signin_path
        fill_in "账号" , with:  siteadmin.name
        fill_in "密码" , with:  siteadmin.password
        click_button "登陆"
      end
      it {should have_link('zone管理员')}
      it {should have_link('设置')      }
      it {should have_link('退出',href:signout_path)}
      it {should_not have_link('登陆',href:signin_path)}
      describe "退出" do
        before  { click_link "退出" }
        it { should have_link('登陆',href:signin_path) }
        it { should have_content('首页') }
      end
    end

    describe "非siteadmin 登陆用户" do
      let(:zoneadmin)   { FactoryGirl.create(:zone_admin) }
      before do
        visit signin_path
        fill_in "账号", with: zoneadmin.name
        fill_in "密码", with: zoneadmin.password
        click_button "登陆"
      end
      it { should_not have_link('zone管理员') }
    end
  end

  describe "ZoneAdmin的首页" do
    
    describe "登陆用户" do
      let(:zoneadmin)   { FactoryGirl.create(:zone_admin) }
      before do
        visit signin_path
        fill_in "账号", with: zoneadmin.name
        fill_in "密码", with: zoneadmin.password
        click_button "登陆"
        cookies[:remember_token] = zoneadmin.remember_token
      end
      it { should have_link('zone管理')}
      it { should have_link('督察员')}
      it {should have_link('退出',href:signout_path)}
      it {should_not have_link('登陆',href:signin_path)}
      it {should have_link('设置')      }
      describe "退出" do
        before  { click_link "退出" }
        it { should have_link('登陆',href:signin_path) }
        it { should_not have_link('设置')      }
        it { should have_content('首页') }
      end
    end

    describe "非zoneadmin登陆用户" do
      let(:zoneadmin_user)  { FactoryGirl.create(:zone_admin,name:"test_for")}
      let(:supervisor_user) { FactoryGirl.create(:supervisor,admin:zoneadmin_user) }
      before do 
        visit signin_path
        fill_in "账号", with: supervisor_user.name
        fill_in "密码", with: supervisor_user.password
        click_button "登陆"
        cookies[:remember_token] = supervisor_user.remember_token
      end
      it { should_not have_link('zone管理')}
    end
  end

  describe "Supervisor的首页" do

    describe "登陆用户" do
      let(:zoneadmin_user)  { FactoryGirl.create(:zone_admin,name:"test_for")}
      let(:supervisor_user) { FactoryGirl.create(:supervisor,admin:zoneadmin_user) }
      before do 
        visit signin_path
        fill_in "账号", with: supervisor_user.name
        fill_in "密码", with: supervisor_user.password
        click_button "登陆"
        cookies[:remember_token] = supervisor_user.remember_token
      end
      it {should have_link('zone') }
      it {should have_link('设置')      }
      it {should have_link('退出',href:signout_path)}
      it {should_not have_link('登陆',href:signin_path)}
      describe "退出" do
        before  { click_link "退出" }
        it { should have_link('登陆',href:signin_path) }
        it { should have_content('首页') }
        it { should_not have_link('zone') }
        it { should_not have_link('设置')      }
      end
    end

    describe "非supervisor 登陆用户" do
      let(:checker_user) { FactoryGirl.create(:checker) }
      before do 
        visit signin_path
        fill_in "账号", with: checker_user.name
        fill_in "密码", with: checker_user.password
        click_button "登陆"
        cookies[:remember_token] = checker_user.remember_token
      end
       it {should_not have_link('zone') }
    end
  end

  describe "Checker的首页" do
    describe "登陆用户" do
      let(:checker_user) { FactoryGirl.create(:checker) }
      before do 
        visit signin_path
        fill_in "账号", with: checker_user.name
        fill_in "密码", with: checker_user.password
        click_button "登陆"
        cookies[:remember_token] = checker_user.remember_token
      end
      it { should have_link('机构') }
      it {should have_link('设置')      }
      it {should have_link('退出',href:signout_path)}
      it {should_not have_link('登陆',href:signin_path)}
      describe "退出" do
        before  { click_link "退出" }
        it { should have_link('登陆',href:signin_path) }
        it { should_not have_link('设置')      }
        it { should have_content('首页') }
      end
    end
  end
 end
