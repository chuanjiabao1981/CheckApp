#encoding:utf-8
require 'spec_helper'

def sigin_visit_category_index(a_template,b_template)
  page.should have_link('新增检查类型',href:new_template_check_category_path(a_template)) 
  a_template.check_categories.each do |cc|
    page.should have_link(cc.category,href:check_category_path(cc))
    page.should have_link('编辑',href:edit_check_category_path(cc))
    page.should have_link('删除',href:check_category_path(cc))
  end
   
  b_template.check_categories.each do |cc|
    page.should_not have_link(cc.category,href:check_category_path(cc))
    page.should_not have_link('编辑',href:edit_check_category_path(cc))
    page.should_not have_link('删除',href:check_category_path(cc))
  end
end

describe "CheckCategories" do
  subject{page}
  let!(:the_site_admin)   { FactoryGirl.create(:site_admin)}
  let!(:a_zone_admin)     { FactoryGirl.create(:zone_admin,name:"a_zone_admin")}
  let!(:b_zone_admin)     { FactoryGirl.create(:zone_admin,name:"b_zone_admin")}
  let!(:a_template_name)             { "静心" }
  let!(:a_template_category1_name)   { "类型一" }
  let!(:a_template_category2_name)   { "类型二" }
  
  let!(:a_template)      { FactoryGirl.create(:template,zone_admin:a_zone_admin,name:a_template_name)}
  let!(:a_category1)     { FactoryGirl.create(:check_category,template:a_template,category:a_template_category1_name)}
  let!(:b_category2)     { FactoryGirl.create(:check_category,template:a_template,category:a_template_category2_name)}
  let!(:a_value)         { FactoryGirl.create(:check_value,template:a_template,boolean_name:"是否铜鼓",date_name:"整改日期",float_name:"搞毛",int_name:"测试")}
  let!(:b_template)      { FactoryGirl.create(:template,zone_admin:b_zone_admin,name:"和顺")}
  let!(:b_value)         { FactoryGirl.create(:check_value,template:b_template,float_name:"指数")}
  let!(:b_category1)      { FactoryGirl.create(:check_category,template:b_template,category:"类型xxx")}


  describe "Index" do
    describe "非登陆用户不能访问" do
      before { get template_check_categories_path(a_template)}
      specify { response.should redirect_to(root_path) }
    end
    describe "登陆的非创建用户不能访问" do
      before do
        sign_in b_zone_admin
        get template_check_categories_path(a_template) 
      end
      specify { response.should redirect_to(root_path) }
    end
    describe "不存在能访问" do
      before do
        sign_in b_zone_admin
        get template_check_categories_path(20111203)
      end
      specify { response.should redirect_to(root_path) }
    end
    describe "登陆的创建用户可以访问" do
      before do
        sign_in a_zone_admin
        click_link('模板')
        click_link(a_template.name)
        click_link(a_template.name)
      end
      specify do
          sigin_visit_category_index a_template,b_template
      end
    end
    describe "登陆site_admin 可以访问" do
      before do
        sign_in the_site_admin
        ##todo::这里改为click
        visit template_check_categories_path(a_template)
      end
      specify do
        sigin_visit_category_index a_template,b_template
      end
    end
  end
end
