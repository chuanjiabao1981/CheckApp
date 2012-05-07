#encoding:utf-8
require 'spec_helper'

describe "Templates" do
  subject{page}
  let(:the_site_admin)   { FactoryGirl.create(:site_admin)}
  let(:a_zone_admin)     { FactoryGirl.create(:zone_admin,name:"a_zone_admin",site_admin:the_site_admin)}
  let(:b_zone_admin)     { FactoryGirl.create(:zone_admin,name:"b_zone_admin",site_admin:the_site_admin)}
  let!(:a_template)      { FactoryGirl.create(:template,zone_admin:a_zone_admin,name:"静心")}
  let!(:a_category1)     { FactoryGirl.create(:check_category,template:a_template,category:"类型一")}
  let!(:b_category2)     { FactoryGirl.create(:check_category,template:a_template,category:"类型二")}
  let!(:a_value)         { FactoryGirl.create(:check_value,
                                                template:a_template,
                                                boolean_name:"是否铜鼓",
                                                date_name:"整改日期",
                                                float_name:"搞毛",
                                                int_name:"测试",
                                                text_name:"备注")}
  let!(:b_template)      { FactoryGirl.create(:template,zone_admin:b_zone_admin,name:"和顺")}
  let!(:b_value)          { FactoryGirl.create(:check_value,template:b_template,float_name:"指数")}
  describe "index 页面" do
    describe "非登陆用户 无法访问" do
      before { get zone_admin_templates_path(a_zone_admin) }
      specify{response.should redirect_to(root_path)}
    end
    describe "登陆非创建用户无法访问" do
      before do
        sign_in b_zone_admin
        get zone_admin_templates_path(a_zone_admin)
      end
      specify{response.should redirect_to(root_path)}
    end
    describe "创建用户登陆" do
      before do
        sign_in a_zone_admin
        ##############sign_in the_site_admin
        visit zone_admin_templates_path(a_zone_admin)
      end
      check_zone_admin_left
      it { should have_link('新增模板',href:new_zone_admin_template_path(a_zone_admin))}
      it { should have_link('编辑',href:edit_template_path(a_template))}
      it { should have_link('删除',href:template_path(a_template))}
      it { should_not have_link('编辑',href:edit_template_path(b_template))}
      it { should have_link(a_template.name,href:template_path(a_template))}
      describe "新增模板" do
        before { click_link('新增模板') }
        describe "提供错误数据" do
           it "模板数不变" do
            expect { click_button '新增模板' }.not_to change(Template,:count)
            page.should have_content('表单有')
           end
        end
        describe "正确数据" do
          let(:temp_name) { "测试一次" }
          before do
            fill_in '模板名', with:temp_name
            check   '督察模板'
            fill_in '是否',   with:"是否合格通过"
            fill_in '日期',   with:"整改日期"
            fill_in '整数',   with:"长度"
            fill_in '小数',   with:"温度"
            fill_in '文字',   with:"备注"
          end

          it "摸板数增加" do
            expect { click_button '新增模板'}.to change(Template,:count).by(1)
            page.should have_content(temp_name)
            a = Template.find_by_name(temp_name)
            a.zone_admin.should == a_zone_admin
            a.should be_for_supervisor
            a.should_not be_for_worker
          end
        end
      end
      describe "模板编辑" do
        before { click_link '编辑' }
        describe "提供错误信息" do
          before do
            fill_in '模板名' ,with:""
            click_button '保存'
          end
          it { should have_content("表单有") }
        end
        describe "提供正确信息" do
          let(:new_temp_name) { "新的末班名字" }
          before do 
            fill_in '模板名', with:new_temp_name
            check  '自查模板'
            click_button '保存'
          end
          specify do
            page.should have_link(new_temp_name) 
            a = Template.find_by_name(new_temp_name) 
            a.should be_for_worker
          end
        end
      end
      describe "模板删除" do
        describe "正常减少" do
          it "-1" do
            expect { click_link '删除' }.to change(Template,:count).by(-1) 
            Template.find_by_name(a_template.name).should be_nil
          end
        end
      end
    end
  end

  describe "浏览单个模板" do
    describe "非登陆用户无法访问" do
      before { get template_path(a_template) }
      specify{response.should redirect_to(root_path)}
    end
    describe "登陆非创建用户无法访问" do
      before do
        sign_in a_zone_admin
        get zone_admin_templates_path(b_template) 
      end
      specify{response.should redirect_to(root_path)}
    end
    describe "zone_admin 登陆" do
      before do 
        sign_in a_zone_admin 
        #sign_in the_site_admin
      end

      describe "访问不存在的template" do
        before { get template_path(20111203) }
        specify { response.should redirect_to(root_path)}
      end

      describe "正常访问" do
        before {visit template_path(a_template)}
        check_zone_admin_left
        it { should have_selector('title',      text:'模板|'+a_template.name)                     }
        it { should have_link('编辑'            ,href:edit_template_path(a_template))                  }
        it { should have_link('新增检查类型'    ,href:new_template_check_category_path(a_template))    }
        it { should have_link(a_template.name   ,href:template_check_categories_path(a_template))      }
        it { should have_selector('td',text:'2')                                                  }
        it { should have_selector('li',text:a_value.boolean_name)                                 }
        it { should have_selector('li',text:a_value.date_name)                                   }
        it { should have_selector('li',text:a_value.float_name)                                   }
        it { should have_selector('li',text:a_value.int_name)                                     }
        it { should have_selector('li',text:a_value.text_name)                                    }
      end
    end
  end
  describe "新增模板" do
    describe "未登陆用户不能访问" do
      before { get new_zone_admin_template_path(a_zone_admin)}
      specify{ response.should redirect_to(root_path)}
    end
    describe "未登录用户不能访问post" do
      before { post  zone_admin_templates_path(a_zone_admin) }
      specify {response.should redirect_to(root_path)}
    end
    describe "登陆的非创建用户" do
      before do
        sign_in b_zone_admin
        get new_zone_admin_template_path(a_zone_admin)
      end
      specify{ response.should redirect_to(root_path)}
    end
    describe "登陆的费创建用户不能Post" do
      before do
        sign_in b_zone_admin
        post zone_admin_templates_path(a_zone_admin)
      end
      specify{ response.should redirect_to root_path }
    end
  end

  describe "模板编辑" do
    describe "未登录用户不能访问 get" do
      before { get edit_template_path(a_template) }
      specify { response.should redirect_to(root_path) }
    end
    describe "未登录用户不能访问 put" do
      before { put template_path(a_template) }
      specify { response.should redirect_to(root_path)}
    end
    describe "登陆的非创建 用户" do
      before do
        sign_in a_zone_admin
        get edit_template_path(b_template) 
      end
      specify { response.should redirect_to(root_path) }
    end
  end
  describe "摸板删除" do
    describe "未登录用户不能访问 delete" do
      before { delete template_path(a_template) }
      specify { response.should redirect_to(root_path) }
    end
    describe "登陆的非创建用户也不能访问" do
      before do
        sign_in a_zone_admin
        delete template_path(b_template) 
      end
      specify{ response.should redirect_to(root_path) }
    end
  end
end
