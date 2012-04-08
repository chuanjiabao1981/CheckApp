#encoding:utf-8
# == Schema Information
#
# Table name: check_values
#
#  id           :integer         not null, primary key
#  boolean_name :string(255)
#  int_name     :string(255)
#  float_name   :string(255)
#  date_name    :string(255)
#  template_id  :integer
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#  can_photo    :boolean         default(FALSE)
#  can_video    :boolean         default(FALSE)
#

require 'spec_helper'

describe CheckValue do
  let(:the_site_admin) { FactoryGirl.create(:site_admin) }
  let(:the_template)   { FactoryGirl.create(:for_supervisor,admin:the_site_admin)}
  before {@the_check_value = the_template.build_check_value(boolean_name:"确认",float_name:"取值",date_name:"整改日期") }
  subject {@the_check_value}
  it { should respond_to(:boolean_name) }
  it { should respond_to(:int_name) }
  it { should respond_to(:date_name)}
  it { should respond_to(:float_name)}
  it { should respond_to(:template)}
  it { should respond_to(:template_id) }
  it { should be_valid }
  describe "不合法情况" do
    describe "没有template_id" do
      before { @the_check_value.template_id = nil }
      it { should_not be_valid}
    end
    describe "全部的名称都为空" do
      before do
        @the_check_value.boolean_name =  @the_check_value.int_name = ""
        @the_check_value.date_name    =  @the_check_value.float_name = ""
      end
      it { should_not be_valid }
    end
    describe "全部名称都为nil" do
      before do
        @the_check_value.boolean_name = @the_check_value.int_name = nil
        @the_check_value.date_name    = @the_check_value.float_name = nil
      end
      it { should_not be_valid }
    end
    describe "boolean 名字太长" do
      before { @the_check_value.boolean_name = "a" * 100 }
      it {should_not be_valid }
    end
    describe "int 名字太长" do
      before {@the_check_value.int_name = "a" * 100 }
      it { should_not be_valid }
    end
    describe "float 名字太长" do
      before { @the_check_value.float_name = "b" * 100}
      it { should_not be_valid }
    end
    describe "date 名字太长" do
      before { @the_check_value.date_name = "b" * 100 }
      it { should_not be_valid }
    end
  end
end
