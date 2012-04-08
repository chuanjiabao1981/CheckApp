#encoding:utf-8
require 'spec_helper'

describe "Templates" do
  subject{page}
  let(:the_site_admin)   { FactoryGirl.create(:site_admin)}
  let(:a_zone_admin)     { FactoryGirl.create(:zone_admin,name:"a_zone_admin")}
  let!(:a_template)      { FactoryGirl.create(:template,admin:the_site_admin,name:"静心")}
  let!(:a_value)         { FactoryGirl.create(:check_value,template:a_template,boolean_name:"是否铜鼓",date_name:"整改日期")}
  let!(:b_template)      { FactoryGirl.create(:template,admin:the_site_admin,name:"和顺")}
  let!(:b_value)          { FactoryGirl.create(:check_value,template:b_template,float_name:"指数")}
  describe "index 页面" do
    describe "非登陆用户 无法访问" do
      before { get templates_path }
      specify{response.should redirect_to(root_path)}
    end
    describe "登陆非site_admin用户无法访问" do
      before do
        sign_in a_zone_admin
        get templates_path
      end
      specify{response.should redirect_to(root_path)}
    end
    describe "site admin登陆" do
      before do
        sign_in the_site_admin
        visit templates_path
      end
      check_site_admin_left
      it { should have_link('新增',href:new_template_path)}
      it { should have_link('编辑',href:edit_template_path(a_template))}
      it { should have_link('删除',href:template_path(a_template))}
      it { should have_link(a_template.name,href:template_path(a_template))}
      it { should have_link('编辑',href:edit_template_path(b_template))}
      it { should have_link('删除',href:template_path(b_template))}
      it { should have_link(b_template.name,href:template_path(b_template))}
    end
  end
end
