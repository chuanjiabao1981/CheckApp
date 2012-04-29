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

def sign_in_visit_category_show(a_category1,b_category1)
    page.should have_selector('title',text:'检查类型|'+a_category1.category)
    page.should have_link('新增检查点',href:new_check_category_check_point_path(a_category1))
    page.should have_link('编辑',href:edit_check_category_path(a_category1))
    page.should have_link(a_category1.category,href:check_category_check_points_path(a_category1))
    page.should_not have_link(b_category1.category,href:edit_check_category_path(b_category1))
    page.should have_content(a_category1.des)  
end

def sign_in_visit_category_new
  describe "提供错误数据" do
    it "categories不能发生变化" do
      expect {click_button '新增检查类型' }.not_to change(CheckCategory,:count)
    end
  end
  describe "提供正确数据" do
    let(:new_category_name) {"ddxxxiaoliaoliao"}
    before do
      fill_in '检查类型名称',with:new_category_name
      fill_in '备注'        ,with:"xxxxxdddowoo li"
    end
    it "检查类型增加" do
      expect {click_button '新增检查类型'}.to change(CheckCategory,:count).by(1)
      a = CheckCategory.find_by_category(new_category_name)
      page.should have_content(a.category)
    end
  end
end

def sign_in_visit_category_destroy
  it "减少1" do
    cps = a_template.check_categories.first.check_points
    expect { click_link '删除'}.to change(CheckCategory,:count).by(-1)
    cps.each do |cp|
      CheckPoint.find_by_id(cp.id).should be_nil
    end
  end
end

def sign_in_visit_category_edit
  describe "提供错误的信息" do
    before do
      fill_in "检查类型名称",with:""
      click_button '保存'
    end
    it "有错误" do
      page.should have_content("表单有") 
    end
  end
  describe "提供正确的信息" do
    let(:new_category_name) {"lia聊"}
    before do
      fill_in "检查类型名称",with:new_category_name
      click_button '保存'
    end
    specify do
      page.should have_link(new_category_name)
      a = CheckCategory.find_by_category(new_category_name)
      page.should have_link(a.category,href:check_category_path(a))
    end
  end
end

describe "CheckCategories" do
  subject{page}
  let!(:the_site_admin)   { FactoryGirl.create(:site_admin)}
  let!(:a_zone_admin)     { FactoryGirl.create(:zone_admin,name:"a_zone_admin",site_admin:the_site_admin)}
  let!(:b_zone_admin)     { FactoryGirl.create(:zone_admin,name:"b_zone_admin",site_admin:the_site_admin)}
  let!(:a_template_name)             { "静心" }
  let!(:a_template_category1_name)   { "类型一" }
  let!(:a_template_category2_name)   { "类型二" }
  
  let!(:a_template)      { FactoryGirl.create(:template,zone_admin:a_zone_admin,name:a_template_name)}
  let!(:a_category1)     { FactoryGirl.create(:check_category,template:a_template,category:a_template_category1_name)}
  let!(:b_category2)     { FactoryGirl.create(:check_category,template:a_template,category:a_template_category2_name)}
  let!(:a_check_point)   { FactoryGirl.create(:check_point,content:"cccccccc1",check_category:a_category1)}
  let!(:a_value)         { FactoryGirl.create(:check_value,template:a_template,boolean_name:"是否铜鼓",date_name:"整改日期",float_name:"搞毛",int_name:"测试")}
  let!(:b_template)      { FactoryGirl.create(:template,zone_admin:b_zone_admin,name:"和顺")}
  let!(:b_value)         { FactoryGirl.create(:check_value,template:b_template,float_name:"指数")}
  let!(:b_category1)     { FactoryGirl.create(:check_category,template:b_template,category:"类型xxx")}
  let!(:b_check_point)   { FactoryGirl.create(:check_point,content:"cccccccccc2",check_category:b_category1)}


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

  describe "Show" do
    describe "非登陆用户无法访问" do
      before { get check_category_path(a_category1)}
      specify{ response.should redirect_to(root_path)}
    end
    describe "登陆非创建用户无法访问" do
      before do
        sign_in b_zone_admin
        get check_category_path(a_category1)
      end
      specify{ response.should redirect_to(root_path)}
    end
    describe "不存在不能访问" do
      before do
        sign_in a_zone_admin
        get check_category_path(20111203)
      end
      specify{ response.should redirect_to(root_path)}
    end
    describe "正常登陆创建用户可以访问" do
      before do
        sign_in a_zone_admin
        click_link('模板')
        click_link(a_template.name)
        click_link(a_template.name)
        click_link(a_category1.category)
      end
      check_zone_admin_left
      specify  do
        sign_in_visit_category_show a_category1,b_category1
      end
    end
    describe "正常登陆的site_admin用户可以访问" do
      before do
        sign_in the_site_admin
        visit check_category_path(a_category1)
      end
      check_site_admin_left
      specify do
        sign_in_visit_category_show a_category1,b_category1
      end
    end
  end
  describe "新增检查类型" do
    describe "未登录用户不能访问" do
      before { get new_template_check_category_path(a_template) }
      specify {response.should redirect_to root_path}
    end
    describe "未登录用户不能Post" do
      before { post template_check_categories_path(a_template) }
      specify{response.should redirect_to root_path}
    end
    describe "登陆非创建用户不能访问" do
      before do
        sign_in b_zone_admin
        get new_template_check_category_path(a_template) 
      end
      specify {response.should redirect_to root_path}
    end
    describe "登陆非创建用户不能Post" do
      before do
        sign_in b_zone_admin
        post template_check_categories_path(a_template)
      end
      specify{response.should redirect_to root_path}
    end
    describe "正常登陆的创建用户" do
      before do
        sign_in a_zone_admin
        click_link('模板')
        click_link(a_template.name)
        click_link(a_template.name)
        click_link('新增检查类型')
      end
      sign_in_visit_category_new
    end
    describe "正常登陆的site_admin" do
      before do
        sign_in the_site_admin
        visit new_template_check_category_path(a_template) 
      end
      sign_in_visit_category_new
    end
  end
  describe "编辑检查类型" do
    describe "未登录用户不能访问" do
      before { get edit_check_category_path(a_category1) }
      specify{response.should redirect_to root_path}
    end
    describe "登陆非创建用户不能访问" do
      before do
        sign_in b_zone_admin
        get edit_check_category_path(a_category1) 
      end
      specify{response.should redirect_to root_path}
    end
    describe "登陆非创建用户不能访问put" do
      before do
        sign_in b_zone_admin
        put check_category_path(a_category1)
      end
      specify{response.should redirect_to root_path}
    end
    describe "访问不存在" do
      before do
        sign_in a_zone_admin
        get edit_check_category_path(20111203)
      end
      specify{response.should redirect_to root_path}
    end
    describe "正常登陆" do
      before do
        sign_in a_zone_admin
        click_link('模板')
        click_link(a_template.name)
        click_link(a_template.name)
        click_link(a_category1.category)
        click_link('编辑')
      end
      check_zone_admin_left
      sign_in_visit_category_edit
    end
    describe "site admin正常登陆" do
      before do
        sign_in the_site_admin
        visit edit_check_category_path(a_category1)
      end
      check_site_admin_left
      sign_in_visit_category_edit
    end
  end
  describe "删除" do
    describe "未登陆用户无法删除" do
      before { delete check_category_path(a_category1) }
      specify{response.should redirect_to root_path}
    end
    describe "登陆的非创建用户无法删除" do
      before do 
        sign_in b_zone_admin
        delete check_category_path(a_category1)
      end
      specify {response.should redirect_to root_path}
    end
    describe "删除不存在" do
      before do
        sign_in a_zone_admin
        delete check_category_path(20111203)
      end
      specify{ response.should redirect_to root_path} 
    end
    describe "正常登陆" do
      before do
        sign_in a_zone_admin
        click_link '模板'
        click_link(a_template.name)
        click_link(a_template.name)
      end
      check_zone_admin_left
      sign_in_visit_category_destroy
    end
    describe "site_admin登陆" do
      before do
        sign_in the_site_admin
        visit template_check_categories_path(a_template)
      end
      check_site_admin_left
      sign_in_visit_category_destroy
    end
  end
end
