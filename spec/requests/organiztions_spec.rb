#encoding:utf-8
require 'spec_helper'


def signin_visit_organization_index 
  specify do
    a_zone.organizations.each do |o|
      page.should have_link(o.name,href:organization_path(o))
      page.should have_link('编辑',href:edit_organization_path(o))
      page.should have_link('删除',href:organization_path(o))
    end
    b_zone.organizations.each do |o|
      page.should_not have_link(o.name,href:organization_path(o))
      page.should_not have_link('编辑',href:edit_organization_path(o))
      page.should_not have_link('删除',href:organization_path(o))
    end
  end
end

def signin_visit_organization_show
  specify do
    page.should have_link('编辑',href:edit_organization_path(a_zone_a_org))
    page.should have_selector('td',text:a_zone_a_org.name)
    page.should have_selector('td',text:a_zone_a_org.contact)
    page.should have_selector('td',text:a_zone_a_org.phone)
    page.should have_selector('td',text:a_zone_a_org.address)
    page.should have_selector('td',text:a_zone_a_org.checker.name)
    page.should have_selector('td',text:a_zone_a_org.worker.name)
  end
end

def signin_visit_organization_new
  describe '提供正确数据' do
    before do
      fill_in '机构名',with:org_name
      fill_in '联系人',with:'ceshiren'
      fill_in '联系电话',with:'111111111'
      fill_in '地址',with:'skk'
      fill_in '自查员账号',with:org_worker
      fill_in '自查员密码',with:'foobar'
      fill_in '自查员密码确认',with:'foobar'
      fill_in '审核员账号',with:org_checker
      fill_in '审核员密码',with:'foobar'
      fill_in '审核员密码确认',with:'foobar'
    end
    it 'org +1' do
      expect {click_button '新增机构'}.to change(Organization,:count).by(1)
    end
    it 'checker +1' do
      expect {click_button '新增机构'}.to change(Checker,:count).by(1)
    end
    it 'worker +1' do
      expect {click_button '新增机构'}.to change(Worker,:count).by(1)
    end
  end
  describe '提供错误数据' do
    describe '无Checker' do
      before do
        fill_in '机构名',with:org_name
        fill_in '联系人',with:'ceshiren'
        fill_in '联系电话',with:'111111111'
        fill_in '地址',with:'skk'
        fill_in '自查员账号',with:org_worker
        fill_in '自查员密码',with:'foobar'
        fill_in '自查员密码确认',with:'foobar'
      end
      it 'org notchange' do
        expect {click_button '新增机构'}.not_to change(Organization,:count)
      end
      it 'woker notchange' do
        expect {click_button '新增机构'}.not_to change(Worker,:count)
      end
      it 'checker notchange' do
        expect {click_button '新增机构'}.not_to change(Checker,:count)
      end
    end
    describe '普通错误' do
      it 'org notchange' do
        expect {click_button '新增机构'}.not_to change(Organization,:count)
      end
      it 'woker notchange' do
        expect {click_button '新增机构'}.not_to change(Worker,:count)
      end
      it 'checker notchange' do
        expect {click_button '新增机构'}.not_to change(Checker,:count)
      end
    end
  end

end
def signin_visit_organization_edit
  describe "提供正确信息" do
    before do
      fill_in '机构名',with:new_org_name
      fill_in '审核员账号',with:new_checker_name
      fill_in '自查员账号',with:new_worker_name
      click_button '保存'
    end
    specify do
      Organization.find_by_name(new_org_name).should_not be_nil
      Checker.find_by_name(new_checker_name).should_not be_nil
      Worker.find_by_name(new_worker_name).should_not be_nil
      page.should have_link(new_org_name,href:organization_path(a_zone_a_org))
    end
  end
  describe "提供错误信息" do
    before do
      fill_in '机构名',with:''
      click_button '保存'
    end
    specify do
      Organization.find_by_name(new_org_name).should be_nil
      Checker.find_by_name(new_checker_name).should be_nil
      Worker.find_by_name(new_worker_name).should be_nil
    end
  end
end
def signin_visit_organization_destroy
  describe '正常删除' do
    it 'org -1' do
      expect {click_link '删除'}.to change(Organization,:count).by(-1)
    end
    it 'worker -1' do
      expect {click_link '删除'}.to change(Organization,:count).by(-1)
    end
    it 'checker -1' do
      expect {click_link '删除'}.to change(Organization,:count).by(-1)
    end
  end
end

describe "Organiztions" do
  let(:the_site_admin) {FactoryGirl.create(:site_admin_with_two_zone_admin)}
  let(:a_zone_admin)   {the_site_admin.zone_admins.first}
  let(:b_zone_admin)   {the_site_admin.zone_admins.last}
  let(:a_zone)         { a_zone_admin.zones.first }
  let(:a_zone_a_org)   { a_zone_admin.zones.first.organizations.first}
  let(:b_zone)  { b_zone_admin.zones.first }

  before do
    a_zone_admin.password = 'foobar'
    b_zone_admin.password = 'foobar'
  end
  subject{page}
  describe "index" do
    describe "非登陆用户" do
      before  { get zone_organizations_path(a_zone) }
      specify { response.should redirect_to root_path}
    end
    describe "登陆非创建用户" do
      before do
        sign_in b_zone_admin
        get zone_organizations_path(a_zone) 
      end
      specify { response.should redirect_to root_path}
    end
    describe "访问不存在" do
      before do
        sign_in a_zone_admin
        get zone_organizations_path(1203)
      end
      specify { response.should redirect_to root_path}
    end
    describe "正常访问" do
      before do
        sign_in a_zone_admin
        click_link 'zone管理'
        click_link a_zone_admin.zones.first.name
        click_link a_zone_admin.zones.first.name
      end
      signin_visit_organization_index
    end
    describe "site admin登陆" do
      before do
        sign_in the_site_admin
        visit zone_organizations_path(a_zone)
      end 
      signin_visit_organization_index
    end
  end
  describe "show" do
    describe '未登录用户' do
      before {get organization_path(a_zone_a_org)}
      specify { response.should redirect_to root_path}
    end
    describe '登陆非创建用户' do
      before do
        sign_in b_zone_admin
        get organization_path(a_zone_a_org)
      end
      specify { response.should redirect_to root_path }
    end
    describe '登陆访问不存在' do  
      before do
        sign_in a_zone_admin
        get organization_path(1203)
      end
      specify { response.should redirect_to root_path }
    end
    describe "正常访问" do
      before do
        sign_in a_zone_admin
        click_link 'zone管理'
        click_link a_zone_admin.zones.first.name
        click_link a_zone_admin.zones.first.name
        click_link a_zone_a_org.name
      end
      signin_visit_organization_show
    end
    describe "site admin访问" do
      before do
        sign_in the_site_admin
        visit organization_path(a_zone_a_org)
      end
      signin_visit_organization_show
    end
  end
  describe "new" do
    let!(:org_name)        {'test_org'}
    let!(:org_checker)     {'test_org_checker'}
    let!(:org_worker)      {'test_org_worker'}
    describe '未登陆' do
      before  { get new_zone_organization_path(a_zone) }
      specify { response.should redirect_to root_path  }
    end
    describe "非创建用户get" do
      before do
        sign_in b_zone_admin
        get new_zone_organization_path(a_zone)
      end
      specify { response.should redirect_to root_path }
    end
    describe "非创建用户post" do
      before do
        sign_in b_zone_admin
        post zone_organizations_path(a_zone)
      end
      specify { response.should redirect_to root_path }
    end
    describe "不存在get" do
      before do
        sign_in a_zone_admin
        get new_zone_organization_path(1203)
      end
      specify { response.should redirect_to root_path }
    end
    describe "不存在post" do
      before do
        sign_in a_zone_admin
        post zone_organizations_path(1203)
      end
      specify { response.should redirect_to root_path }
    end
    describe "正常登陆" do
      before do 
        sign_in a_zone_admin
        click_link 'zone管理'
        click_link a_zone_admin.zones.first.name
        click_link a_zone_admin.zones.first.name
        click_link '新增机构'
      end
      signin_visit_organization_new
    end
    describe "the siteadmin登陆" do
      before do
        sign_in the_site_admin
        visit new_zone_organization_path(a_zone)
      end
      signin_visit_organization_new
    end
  end
  describe "edit" do
    let(:new_org_name) {'新名字'}
    let(:new_checker_name) {'new_checker_name'}
    let(:new_worker_name)  {'new_worker_name'}
    describe "未登录用户" do
      before { get edit_organization_path(a_zone_a_org) }
      specify { response.should redirect_to root_path }
    end
    describe "非创建用户get" do
      before do
        sign_in b_zone_admin
        get edit_organization_path(a_zone_a_org)
      end
      specify { response.should redirect_to root_path }
    end
    describe "非创建用户put" do
      before do
        sign_in b_zone_admin
        put organization_path(a_zone_a_org)
      end
      specify{ response.should redirect_to root_path }
    end
    describe "不存在get" do
      before do
        sign_in a_zone_admin
        get edit_organization_path(1203)
      end
      specify { response.should redirect_to root_path }
    end
    describe "不存在 put" do
      before do
        sign_in a_zone_admin
        put organization_path(1203)
      end
      specify { response.should redirect_to root_path}
    end
    describe "正常登陆" do
      before do
        sign_in a_zone_admin
        click_link 'zone管理'
        click_link a_zone_admin.zones.first.name
        click_link a_zone_admin.zones.first.name
        click_link '编辑'
      end
      signin_visit_organization_edit
    end
    describe "site admin登陆" do
      before do
        sign_in the_site_admin
        visit edit_organization_path(a_zone_a_org)
      end
      signin_visit_organization_edit
    end
  end
  describe "destroy" do
    describe "未登录用户" do
      before { delete organization_path(a_zone_a_org) }
      specify {response.should redirect_to root_path}
    end
    describe "登陆非创建用户" do
      before do
        sign_in b_zone_admin
        delete organization_path(a_zone_a_org)
      end
      specify { response.should redirect_to root_path }
    end
    describe "不存在" do
      before { delete organization_path(1203) }
      specify { response.should redirect_to root_path }
    end
    describe "正常登陆" do
      before do
        sign_in a_zone_admin
        click_link 'zone管理'
        click_link a_zone_admin.zones.first.name
        click_link a_zone_admin.zones.first.name
      end
      signin_visit_organization_destroy
    end
    describe "siteadmin 登陆" do
      before do
        sign_in the_site_admin
        visit zone_organizations_path(a_zone)
      end
      signin_visit_organization_destroy
    end
  end
end
