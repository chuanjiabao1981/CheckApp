#encoding:utf-8
# == Schema Information
#
# Table name: check_categories
#
#  id          :integer         not null, primary key
#  category    :string(255)
#  des         :string(255)
#  template_id :integer
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

require 'spec_helper'

describe CheckCategory do
  let(:the_site_admin) { FactoryGirl.create(:site_admin) }
  let(:a_zone_admin)   { FactoryGirl.create(:zone_admin) }
  let(:the_template)   { FactoryGirl.create(:for_supervisor,zone_admin:a_zone_admin) }

  before {@check_category = the_template.check_categories.build(category:"手续检查",des:"测试水平")}
  #before {@check_category = FactoryGirl.build(:check_category) }

  subject{@check_category}

  it { should respond_to(:category) }
  it { should respond_to(:des)  }
  it { should respond_to(:template_id) }
  it { should respond_to(:check_points) }
  it { should respond_to(:template) }
  it { should be_valid}

  describe "错误数据" do
    describe "category 太长了" do 
      before { @check_category.category = "a" * 500 }
      it { should_not be_valid } 
    end
    describe "des 太长了" do
      before { @check_category.des = "你" *1000}
      it { should_not be_valid } 
    end
    describe "没有template" do
      before {@check_category.template_id = nil }
      it { should_not be_valid}
    end
  end
end
