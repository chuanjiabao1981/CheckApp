# encoding: utf-8
require 'spec_helper'

describe "AdminPages" do
  subject { page }
  describe "visit admin show" do
    let(:admin) {   FactoryGirl.create(:admin)              }
    before      {   visit admin_path(admin)                 }
    it { should have_selector('td',text:admin.name)         }
    it { should have_selector('td',text:admin.des)          }
    it { should have_selector('td',text:admin.contact)      }
    it { should have_selector('td',text:admin.phone)        }  
  end

  describe "visit not exsits admin" do
    before    {   get admin_path(123)   }
    specify   {response.should redirect_to (admins_path) }
  end
  
  describe "add a new admin" do
    before  { visit new_admin_path }
    describe "填充无效结果" do
      it "不应该添加管理员账户" do
        expect { click_button "确定" }.not_to change(Admin,:count)
      end
    end
    describe "添加合法信息" do
      before do
        fill_in "账号",                     with:"test_id_123"
        fill_in "密码",                     with:"123456"
        fill_in "密码确认",                 with:"123456"
        fill_in "描述"              ,       with:"来自于宇宙"
        fill_in "联系人"              ,     with:"马润清"
        fill_in "联系电话"                , with:"15910666323"
      end
      it "应当创建一个新的amdin用户" do
        expect do
          click_button "确定"
        end.to  change(Admin,:count).by(1)
      end
    end
  end
end
