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
    describe "正常登陆" do
      let!(:org_name)        {'test_org'}
      let!(:org_checker)     {'test_org_checker'}
      let!(:org_worker)      {'test_org_worker'}
      before do 
        sign_in a_zone_admin
        click_link 'zone管理'
        click_link a_zone_admin.zones.first.name
        click_link a_zone_admin.zones.first.name
        click_link '新增机构'
      end
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
        describe '无worker' do
        end
        describe '普通错误' do
        end
      end
    end
  end
end
