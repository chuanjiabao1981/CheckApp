#encoding:utf-8
require 'spec_helper'

def sign_in_visit_zone_supervisor_index
  specify do
    page.should have_link('添加督察员',href:new_zone_admin_zone_supervisor_path(a_zone_admin))
    a_zone_admin.supervisors.each  do |s|
      page.should have_link('编辑',href:edit_zone_supervisor_path(s))
      page.should have_link('删除',href:zone_supervisor_path(s))
      page.should have_link(s.name,href:zone_supervisor_path(s)) 
    end
    b_zone_admin.supervisors.each  do |s|
      page.should_not have_link('编辑',href:edit_zone_supervisor_path(s)) 
      page.should_not have_link('删除',href:zone_supervisor_path(s))
      page.should_not have_link(s.name,href:zone_supervisor_path(s)) 
    end
  end
end

def sign_in_visit_zone_supervisor_show(a_zone_supervisor1)
  page.should have_link('编辑',href:edit_zone_supervisor_path(a_zone_supervisor1)) 
  page.should have_selector('title',text:'督察员|'+a_zone_supervisor1.name)
  page.should have_content(a_zone_supervisor1.name) 
end

def sign_in_visit_zone_supervisor_new
  describe '提供错误信息' do
    it '不增加' do
      expect { click_button '添加督察员'}.not_to change(User,:count)
    end
  end
  describe '提供正确信息' do
    let(:new_supervisor_name) {"12345dd"}
    before do
      fill_in '督察员账号',with:new_supervisor_name
      fill_in '密码'      ,with:'foobar'
      fill_in '确认密码'  ,with:'foobar'
      fill_in '备注'  ,with:'123'
    end
    it '增加' do
      expect { click_button '添加督察员'}.to change(User,:count).by(1)
      a = User.find_by_name(new_supervisor_name)
      a.should be_zone_supervisor
    end
  end
end

def sign_in_visit_zone_supervisor_edit
  describe '提供错误信息' do
    before do
      fill_in '督察员账号',with:""
      click_button '保存'
    end
    it { should have_content('表单有') }
  end
  describe '提供正确信息' do
    let!(:new_supervisor_name_str) {"newNameS"}
    before do
      fill_in '督察员账号',with:new_supervisor_name_str
      click_button '保存'
    end
    specify do
      a =User.find_by_name(new_supervisor_name_str)
      a.should_not be_nil
      page.should have_link('编辑',href:edit_zone_supervisor_path(a))
    end
  end
end

def sign_in_visit_zone_supervisor_destroy
  it '-1' do
    expect { click_link '删除' }.to change(User,:count).by(-1)
    page.should_not have_content(a_zone_supervisor1.name)
    page.should have_content(a_zone_supervisor2.name)
  end
end

describe "ZoneSupervisors" do
  subject { page }
  let!(:the_site_admin)       { FactoryGirl.create(:site_admin)}
  let!(:a_zone_admin)         { FactoryGirl.create(:zone_admin,name:"a_zone_admin")}
  let!(:b_zone_admin)         { FactoryGirl.create(:zone_admin,name:"b_zone_admin")}
  let!(:a_zone_supervisor1)   { FactoryGirl.create(:supervisor,name:"a_zone_supervisor1",admin:a_zone_admin) }
  let!(:a_zone_supervisor2)   { FactoryGirl.create(:supervisor,name:"a_zone_supervisor2",admin:a_zone_admin) }
  let!(:b_zone_supervisor1)   { FactoryGirl.create(:supervisor,name:"b_zone_supervisor1",admin:b_zone_admin) }
  let!(:b_zone_supervisor2)   { FactoryGirl.create(:supervisor,name:"b_zone_supervisor2",admin:b_zone_admin) }


  describe "Index" do
    describe "未登录用户不能访问" do
      before { get zone_admin_zone_supervisors_path(a_zone_admin) }
      specify { response.should redirect_to root_path }
    end
    describe "登陆非创建用户不能访问" do
      before do
        sign_in a_zone_admin
        get zone_admin_zone_supervisors_path(b_zone_admin)
      end
      specify { response.should redirect_to root_path }
    end
    describe "访问不存在的zone_admin的supervisor列表" do
      before do
        sign_in a_zone_admin 
        get zone_admin_zone_supervisors_path(20111203)
      end
      specify { response.should redirect_to root_path }
    end 
    describe "正常登陆用户" do
      before do
        sign_in a_zone_admin
        click_link '督察员'
      end
      check_zone_admin_left
      sign_in_visit_zone_supervisor_index
    end
    describe "site_admin用户登陆" do
      before do
        sign_in the_site_admin
        visit zone_admin_zone_supervisors_path(a_zone_admin)
      end
      check_site_admin_left
      sign_in_visit_zone_supervisor_index
    end
  end
  describe "Show" do
    describe "未登录用户不能访问" do
      before { get zone_supervisor_path(a_zone_supervisor1) }
      specify {response.should redirect_to root_path }
    end
    describe "登陆非创建用户" do
      before do
        sign_in b_zone_admin
        get zone_supervisor_path(a_zone_supervisor1)
      end
      specify { response.should redirect_to root_path }
    end
    describe "访问不存在的" do
      before do
        sign_in a_zone_admin
        get zone_supervisor_path(20111203)
      end
      specify { response.should redirect_to root_path }
    end
    describe "正常登陆用户" do
      before do
        sign_in a_zone_admin
        click_link '督察员'
        click_link a_zone_supervisor1.name
      end
      check_zone_admin_left
      specify do
        sign_in_visit_zone_supervisor_show a_zone_supervisor1
      end
    end
    describe "site admin登陆" do
      before do
        sign_in the_site_admin
        visit zone_supervisor_path(a_zone_supervisor1)
      end
      check_site_admin_left
      specify do
        sign_in_visit_zone_supervisor_show a_zone_supervisor1
      end
    end
  end
  describe "New" do
    describe "未登录用户访问" do
      before { get new_zone_admin_zone_supervisor_path(a_zone_admin) }
      specify { response.should redirect_to root_path } 
    end 
    describe "未登录用户Post" do
      before { post zone_admin_zone_supervisors_path(a_zone_admin) }
      specify {response.should redirect_to root_path }
    end
    describe "登陆非创建用户" do
      before do
        sign_in b_zone_admin
        get new_zone_admin_zone_supervisor_path(a_zone_admin)
      end
      specify { response.should redirect_to root_path }
    end
    describe "登陆非创建用户Post" do
      before do
        sign_in b_zone_admin
        post zone_admin_zone_supervisors_path(a_zone_admin)
      end
      specify { response.should redirect_to root_path }
    end
    describe "正常登陆用户" do
      before do
        sign_in a_zone_admin
        click_link '督察员'
        click_link '添加督察员'
      end
      check_zone_admin_left
      sign_in_visit_zone_supervisor_new
    end
    describe "site admin登陆" do
      before do
        sign_in the_site_admin
        visit new_zone_admin_zone_supervisor_path(a_zone_admin)
      end
      check_site_admin_left
      sign_in_visit_zone_supervisor_new
    end
  end
  describe "Edit" do
    describe "未登录用户" do
      before { get zone_supervisor_path(a_zone_supervisor1) }
      specify { response.should redirect_to root_path }
    end
    describe "非创建用户登陆" do
      before do
        sign_in b_zone_admin
        get zone_supervisor_path(a_zone_supervisor1)
      end
      specify { response.should redirect_to root_path }
    end
    describe "非创建用户Put" do
      before do
        sign_in b_zone_admin
        put zone_supervisor_path(a_zone_supervisor1)
      end
      specify { response.should redirect_to root_path }
    end
    describe "正常登陆" do
      before do
        sign_in a_zone_admin
        click_link '督察员'
        click_link '编辑'
      end
      check_zone_admin_left
      sign_in_visit_zone_supervisor_edit
    end
    describe "site_admin登陆" do
      before do
        sign_in the_site_admin
        visit edit_zone_supervisor_path(a_zone_supervisor1)
      end
      check_site_admin_left
      sign_in_visit_zone_supervisor_edit
    end
  end
  describe "Destroy" do
    describe "未登录用户" do
      before { delete zone_supervisor_path(a_zone_supervisor1) }
      specify {response.should redirect_to root_path }
    end
    describe "非创建用户登陆" do
      before do
        sign_in b_zone_admin
        delete zone_supervisor_path(a_zone_supervisor1)
      end
      specify { response.should redirect_to root_path }
    end
    describe '删除不存在' do
      before do
        sign_in a_zone_admin
        delete zone_supervisor_path(20111203)
      end
      specify { response.should redirect_to root_path }
    end
    describe "正常登陆" do
      before do
        sign_in a_zone_admin
        click_link '督察员'
      end
      check_zone_admin_left
      sign_in_visit_zone_supervisor_destroy
    end
    describe "site_admin" do
      before do
        sign_in the_site_admin
        visit zone_admin_zone_supervisors_path(a_zone_admin)
      end
      check_site_admin_left
      sign_in_visit_zone_supervisor_destroy
    end
  end
end
