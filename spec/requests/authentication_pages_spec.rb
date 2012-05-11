#encoding: utf-8
require 'spec_helper'

describe "AuthenticationPages" do
  subject { page }
#  describe "登陆页面" do
#    before { visit signin_path }
#    it { should have_selector('h1',    text: '登陆') }
#    it { should have_selector('title', text: '登陆') }
#  end
#  describe "登陆" do
#    before { visit signin_path }
#    describe "错误登陆" do
#      before { click_button "登陆" }
#      it { should have_selector('title',text:'登陆') }
#      it { should have_selector('div.alert.alert-error', text: '账号或密码错误')}
#    end
#  end
#
#  describe "错误用户登陆" do
#    let(:invalid_user) { FactoryGirl.create(:user) }
#    before do
#      visit signin_path
#      fill_in "账号" , with:  invalid_user.name
#      fill_in "密码" , with:  invalid_user.password
#      click_button "登陆"
#    end
#    it { should have_selector('div.alert.alert-error',text: '账号未启用')}
#  end

  describe "site admin登陆" do

    before { visit site_admin_signin_path }
    describe "登陆页面" do
      it { should have_selector('h2', text:'系统管理员登陆') }
      it { should have_selector('title',text:'登陆') }
    end
    describe "错误登陆" do
      before { click_button "登陆" }
      it { should have_selector('h2',text:"系统管理员登陆") }
      it { should have_selector('div.alert.alert-error',text:'账号或密码错误')}
    end
    describe "正常登陆" do
      let(:the_site_admin) { FactoryGirl.create(:site_admin) }
      before do
        fill_in "账号", with:the_site_admin.name 
        fill_in "密码", with:the_site_admin.password
        click_button "登陆"
      end
      check_site_admin_left
    end
  end
end
