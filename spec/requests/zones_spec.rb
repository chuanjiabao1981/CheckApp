#encoding:utf-8
require 'spec_helper'

def signin_visit_zone_index
  specify do
    page.should have_link('新增分区',href:new_zone_admin_zone_path(a_zone_admin))
    a_zone_admin.zones.each do |z|
      page.should have_link(z.name,href:zone_path(z))
      page.should have_link('编辑',href:edit_zone_path(z))
      page.should have_link('删除',href:zone_path(z))
    end
    b_zone_admin.zones.each do |z|
      page.should_not have_link(z.name,href:zone_path(z))
      page.should_not have_link('编辑',href:edit_zone_path(z))
      page.should_not have_link('删除',href:zone_path(z))
    end
  end
end

def signin_visit_zone_show
  specify do
    page.should have_link('新增机构',href:new_zone_organization_path(a_zone_1))
    page.should have_link('编辑',href:edit_zone_path(a_zone_1))
    page.should have_link(a_zone_1.name,href:zone_organizations_path(a_zone_1))
    page.should have_selector('td',text:a_zone_1.des)
    a_zone_1.zone_supervisors.each do |zs|
      page.should have_selector('li',text:zs.name)
    end
  end
end

def sigin_visit_zone_new
  describe "提供正确信息" do
    let(:new_zone_name)           { "测试zone1"}
    let(:new_zone_des)            { "测试备注" }
    let(:a_zone_supervisor_1)     { a_zone_admin.zone_supervisors.first }
    let(:a_zone_supervisor_2)     { a_zone_admin.zone_supervisors.last }
    before do
      fill_in 'Zone名称',with:new_zone_name
      fill_in '备注',    with:new_zone_des
      page.find('css', "#zone_zone_supervisor_ids_[value='#{a_zone_supervisor_1.id}']").set(true)
      page.find('css', "#zone_zone_supervisor_ids_[value='#{a_zone_supervisor_2.id}']").set(true)
      #check a_zone_supervisor_1.name
      #check a_zone_supervisor_2.name
    end
    it "zone增加1" do
      expect{ click_button '新增分区'}.to change(Zone,:count).by(1)
    end
    it "zone supervisor relation增加1" do
      expect { click_button '新增分区'}.to change(ZoneSupervisorRelation,:count).by(2)
    end
  end
  describe "提供错误信息" do
    it "zone不增加" do
      expect { click_button '新增分区'}.not_to change(Zone,:count)
    end
  end

end

def sign_in_visit_zone_edit
  describe "正确编辑" do
    let(:new_zone_name) { "测试赛"}
    let(:new_zone_des)  { "测试啊"}
    let(:a_zone_supervisor_1)     { a_zone_admin.zone_supervisors.first }
    let(:a_zone_supervisor_2)     { a_zone_admin.zone_supervisors.last }
    before do
      fill_in 'Zone名称',with:new_zone_name
      page.find('css', "#zone_zone_supervisor_ids_[value='#{a_zone_supervisor_1.id}']").set(false)
      #uncheck a_zone_supervisor_1.name
      page.find('css', "#zone_zone_supervisor_ids_[value='#{a_zone_supervisor_2.id}']").set(true)
      #check a_zone_supervisor_2.name
      click_button '保存'
    end
    specify do
      Zone.find_by_name(new_zone_name).should_not be_nil
      a_zone_1.zone_supervisor_ids.should include(a_zone_supervisor_2.id)
      a_zone_1.zone_supervisor_ids.should_not include(a_zone_supervisor_1.id)
    end
  end
  describe "错误编辑" do
    before do
      fill_in 'Zone名称',with:""
      click_button '保存'
    end
    specify do  
      Zone.find_by_name(a_zone_1.name).should_not be_nil
    end
  end

end

describe "Zones" do
  let(:the_site_admin) { FactoryGirl.create(:site_admin_with_two_zone_admin) }
  let(:a_zone_admin)   { the_site_admin.zone_admins.first }
  let(:b_zone_admin)   { the_site_admin.zone_admins.last  }
  let(:a_zone_1)       { a_zone_admin.zones.first         }
  let(:a_zone_2)       { a_zone_admin.zones.last          }
  before do
    a_zone_admin.password = 'foobar'
    b_zone_admin.password = 'foobar'
  end
  subject{page}
  describe "Index" do
    describe "未登录用户" do
      before { get zone_admin_zones_path(a_zone_admin) }
      specify { response.should redirect_to root_path}
    end
    describe "登陆的非创建用户" do
      before do 
        sign_in b_zone_admin
        get zone_admin_zones_path(a_zone_admin) 
      end
      specify { response.should redirect_to root_path }
    end
    describe "访问不存在的" do
      before do
        sign_in b_zone_admin
        get zone_admin_zones_path(1203)
      end
      specify { response.should redirect_to root_path }
    end
    describe "正常用户登陆" do
      before do
        sign_in a_zone_admin
        visit zone_admin_zones_path(a_zone_admin)
      end
      signin_visit_zone_index
    end
    describe "site_amdin登陆" do
      before do
        sign_in the_site_admin
        visit zone_admin_zones_path(a_zone_admin)
      end
      signin_visit_zone_index
    end
  end
  describe "Show" do
    describe "未登录用户访问" do
      before { get zone_path(a_zone_1)}
      specify { response.should redirect_to root_path }
    end
    describe "非创建用户访问" do  
      before do
        sign_in b_zone_admin
        get zone_path(a_zone_1)
      end
      specify { response.should redirect_to root_path}
    end
    describe "登陆用户访问不存" do
      before do
        sign_in a_zone_admin
        get zone_path(1203)
      end
      specify {response.should redirect_to root_path}
    end
    describe "正常登陆" do
      before do
        a_zone_1.zone_supervisors<<a_zone_admin.zone_supervisors.first
        a_zone_1.zone_supervisors<<a_zone_admin.zone_supervisors.last
        sign_in a_zone_admin
        click_link 'zone管理'
        click_link a_zone_1.name
      end
      signin_visit_zone_show
    end
    describe "siteadmin登陆" do
      before do
        a_zone_1.zone_supervisors<<a_zone_admin.zone_supervisors.first
        a_zone_1.zone_supervisors<<a_zone_admin.zone_supervisors.last
        sign_in the_site_admin
        visit zone_path(a_zone_1)
      end
      signin_visit_zone_show
    end
  end
  describe "New" do
    describe "非登陆用户" do
      before { get new_zone_admin_zone_path(a_zone_admin) }
      specify { response.should redirect_to root_path}
    end
    describe "非创建用户 Get" do
      before do
        sign_in b_zone_admin
        get new_zone_admin_zone_path(a_zone_admin) 
      end
      specify { response.should redirect_to root_path }
    end
    describe "非创建用户Post" do
      before do
        sign_in b_zone_admin
        post zone_admin_zones_path(a_zone_admin)
      end
      specify {response.should redirect_to root_path}
    end
    describe "正常登陆" do
      before do
        sign_in a_zone_admin
        click_link 'zone管理'
        click_link '新增分区'
      end
      sigin_visit_zone_new
    end
    describe "SiteAdmin登陆" do
      before do
        sign_in the_site_admin
        visit new_zone_admin_zone_path(a_zone_admin)
      end
      sigin_visit_zone_new
    end
  end
  describe "Edit" do
    let(:a_zone_supervisor_1)     { a_zone_admin.zone_supervisors.first }
    let(:a_zone_supervisor_2)     { a_zone_admin.zone_supervisors.last }

    describe "正常登陆" do
      before do
        a_zone_1.zone_supervisors<<a_zone_supervisor_1
        sign_in a_zone_admin
        click_link 'zone管理'
        click_link '编辑'
      end
      sign_in_visit_zone_edit
    end
    describe "site admin登陆" do
      before do
        a_zone_1.zone_supervisors<<a_zone_supervisor_1
        sign_in the_site_admin
        visit edit_zone_path(a_zone_1)
      end
      sign_in_visit_zone_edit
    end
  end

  describe "destroy" do
    describe "正常登陆" do
      before do
        sign_in a_zone_admin
        click_link 'zone管理'
        click_link '删除'
      end
      it '减少1' do
        expect{click_link '删除'}.to change(Zone,:count).by(-1)
      end
    end
  end
end
