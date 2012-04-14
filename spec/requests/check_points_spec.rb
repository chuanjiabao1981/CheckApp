#encoding:utf-8
require 'spec_helper'

def sign_in_visit_check_point_index
  it {should have_link('编辑',href:edit_check_point_path(a_check_point))}
  it {should have_link('删除',href:check_point_path(a_check_point))}
  it {should have_link('新增检查点',href:new_check_category_check_point_path(a_category1))}
  it {should have_content(a_check_point.content)}
  it {should have_content('是')}
end

def site_in_visit_check_point_new
  describe "错误数据" do
    it "不会增加数据" do
      expect { click_button '新增检查点' }.not_to change(CheckPoint,:count)
      page.should have_content('表单有')
    end
  end
  describe "正确数据" do
    let(:check_point_content_str) { '检查啊检查，你要怎么检查' }
    before do
      fill_in '检查内容描述',with:check_point_content_str
      check '需要图片'
    end
    it "增加一个数据" do
      expect { click_button '新增检查点' }.to change(CheckPoint,:count).by(1)
      page.should have_content(check_point_content_str)
      a = CheckPoint.find_by_content(check_point_content_str)
      a.should be_can_photo
    end
  end
end

def sign_in_visit_check_point_edit
  describe "提供错误数据" do
    before do
      fill_in "检查内容描述",with:""
      click_button '保存'
    end
    it "返回错误" do
      page.should have_content("表单有")
    end
  end
  describe "提供正确数据" do
    let(:new_check_point_content_for_edit_str) {"caodan de xiaoliaoliao"}
    before do
      fill_in "检查内容描述",with:new_check_point_content_for_edit_str
      uncheck '需要图片'
      click_button '保存'
    end
    it '正确' do
      page.should have_content(new_check_point_content_for_edit_str)
      a = CheckPoint.find_by_content(new_check_point_content_for_edit_str)
      a.should_not be_can_photo
    end
  end
end

def sign_in_visit_check_point_destroy
  it '-1' do
    expect { click_link '删除' }.to change(CheckPoint,:count).by(-1)
    #todo:: 记录点删除
  end
end

describe "CheckPoints" do
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
  let!(:a_check_point)   { FactoryGirl.create(:check_point,content:"cccccccc1",check_category:a_category1,can_photo:true)}
  let!(:a_value)         { FactoryGirl.create(:check_value,template:a_template,boolean_name:"是否铜鼓",date_name:"整改日期",float_name:"搞毛",int_name:"测试")}
  let!(:b_template)      { FactoryGirl.create(:template,zone_admin:b_zone_admin,name:"和顺")}
  let!(:b_value)         { FactoryGirl.create(:check_value,template:b_template,float_name:"指数")}
  let!(:b_category1)     { FactoryGirl.create(:check_category,template:b_template,category:"类型xxx")}
  let!(:b_check_point)   { FactoryGirl.create(:check_point,content:"cccccccccc2",check_category:b_category1)}

  describe "Index" do
    describe "非登陆用户不能访问" do
      before { get check_category_check_points_path(a_category1) }
      specify{response.should redirect_to root_path       }
    end
    describe "登陆的非创建用户不能访问" do
      before do
        sign_in b_zone_admin
        get check_category_check_points_path(a_category1) 
      end
      specify { response.should redirect_to root_path }
    end
    describe "访问不存在的检查列表" do
      before do
        sign_in a_zone_admin
        get check_category_check_points_path(20111203)
      end
      specify { response.should redirect_to root_path }
    end
    describe "正常登陆" do
      before do
        sign_in a_zone_admin
        click_link '模板'
        click_link(a_template.name)
        click_link(a_template.name)
        click_link(a_category1.category)
        click_link(a_category1.category)
      end
        check_zone_admin_left
        sign_in_visit_check_point_index
    end
    describe "site admin登陆" do
      before do
        sign_in the_site_admin
        visit check_category_check_points_path(a_category1)
      end
      check_site_admin_left
      sign_in_visit_check_point_index
    end
  end

  describe "New" do
    describe "非登陆用户不能访问" do
      before  { get new_check_category_check_point_path(a_category1) }
      specify { response.should redirect_to root_path }
    end
    describe "非登陆用户不能访问POST" do
      before  { post check_category_check_points_path(a_category1) }
      specify { response.should redirect_to root_path }
    end
    describe "登陆非创建用户不能访问" do
      before do
        sign_in b_zone_admin
        get new_check_category_check_point_path(a_category1) 
      end
      specify { response.should redirect_to root_path }
    end
    describe "登陆非创建用户不能Post" do
      before do 
        sign_in b_zone_admin
        post check_category_check_points_path(a_category1) 
      end
      specify { response.should redirect_to root_path }
    end
    describe "正常登陆" do
      before do
        sign_in a_zone_admin
        click_link '模板'
        click_link(a_template.name)
        click_link(a_template.name)
        click_link(a_category1.category)
        click_link(a_category1.category)
        click_link('新增检查点')
      end
      check_zone_admin_left
      site_in_visit_check_point_new
    end
    describe "site_admin登陆" do
      before do
        sign_in the_site_admin
        visit new_check_category_check_point_path(a_category1)
      end
      check_site_admin_left
      site_in_visit_check_point_new
    end
  end

  describe "Edit" do
    describe "非登陆用户不能访问" do
      before  { get edit_check_point_path(a_check_point) }
      specify { response.should redirect_to root_path }
    end
    describe "登陆的非创建用户不能访问" do
      before do 
        sign_in b_zone_admin
        get edit_check_point_path(a_check_point)
      end
      specify { response.should redirect_to root_path  }
    end
    describe "访问不存在的不能访问" do
      before do
        sign_in a_zone_admin
        get edit_check_point_path(20111203)
      end
      specify { response.should redirect_to root_path  }
    end
    describe "正常登陆" do
      before do
        sign_in a_zone_admin
        click_link '模板'
        click_link(a_template.name)
        click_link(a_template.name)
        click_link(a_category1.category)
        click_link(a_category1.category)
        click_link('编辑')
      end
      check_zone_admin_left
      sign_in_visit_check_point_edit
    end
    describe "site_admin 登陆" do
      before do
        sign_in the_site_admin
        visit edit_check_point_path(a_check_point) 
      end
      check_site_admin_left
      sign_in_visit_check_point_edit
    end
  end
  describe "destroy" do
    describe "未登录用户不能访问" do
      before { delete check_point_path(a_check_point) }
      specify { response.should redirect_to root_path }
    end
    describe "登陆非创建用户不能访问" do
      before do
        sign_in b_zone_admin
        delete check_point_path(a_check_point) 
      end
      specify { response.should redirect_to root_path }
    end
    describe "删除不存在的" do
      before do
        sign_in a_zone_admin
        delete check_point_path(20111203)
      end
      specify{ response.should redirect_to root_path }
    end
    describe "正常登陆" do
      before do
        sign_in a_zone_admin
        click_link '模板'
        click_link(a_template.name)
        click_link(a_template.name)
        click_link(a_category1.category)
        click_link(a_category1.category)
      end
      sign_in_visit_check_point_destroy
    end
    describe "site admin" do
      before do
        sign_in the_site_admin
        visit check_category_check_points_path(a_category1)
      end
      sign_in_visit_check_point_destroy
    end
  end
end
