#encoding:utf-8
# == Schema Information
#
# Table name: templates
#
#  id             :integer         not null, primary key
#  name           :string(255)
#  for_supervisor :boolean
#  for_worker     :boolean
#  admin_id       :integer
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#  can_video      :boolean         default(FALSE)
#  can_photo      :boolean         default(FALSE)
#

require 'spec_helper'

def normal_test
  describe "不合法的情况" do
    describe "名字为空" do
      before { @template.name = " " }
      it { should_not be_valid }
    end
    describe "admin_id为空" do
      before { @template.zone_admin_id = nil }
      it { should_not be_valid }
    end
    describe "重复的" do
      before do
        dup_temp = @template.dup
        dup_temp.save
      end
      it { should_not be_valid }
    end
    describe "名字过长" do
      before { @template.name ="a"* 200}
      it { should_not be_valid }
    end
  end
end

describe Template do
  let(:the_site_admin)      { FactoryGirl.create(:site_admin) }
  let(:a_zone_admin)        { the_site_admin.zone_admins.create(name:"testme",password:"foobar",password_confirmation:"foobar") }
  let(:a_zone)              { a_zone_admin.zones.create(name:"123",des:"3333") }
  let(:a_zone_supervisor)   { a_zone_admin.zone_supervisors.create(name:"222",password:"foobar",password_confirmation:"foobar") }

  before { @template=a_zone_admin.templates.build(name:'test_template',for_supervisor:true,for_worker:false,check_value_attributes:{boolean_name:"b1",date_name:"d1"})}
  subject { @template }
  it { should be_valid}
  it { should respond_to(:name) }
  it { should respond_to(:for_supervisor) }
  it { should respond_to(:for_worker)}
  it { should respond_to(:zone_admin) }
  it { should respond_to(:check_categories) }
  it { should be_for_supervisor}
  it { should_not be_for_worker }
  it { should respond_to(:check_value) }

  describe "nest attribute test" do
    specify do
      a = a_zone_admin.templates.create(
            name:"test_template_2",
            for_supervisor:true,
            check_value_attributes: { boolean_name:"b1",date_name:"d1" } 
          )
      a.should be_valid
    end
  end

  describe "测试关联关系" do
    let!(:a_template)      {a_zone_admin.templates.create(name:'test_template2',
                            for_supervisor:true,
                            for_worker:false,
                            check_value_attributes:{boolean_name:"b1",date_name:"d1",text_name:"备注"})}
    let!(:a_category1)     { FactoryGirl.create(:check_category,template:a_template,category:"类型一")}
    let!(:b_category2)     { FactoryGirl.create(:check_category,template:a_template,category:"类型二")}
    let!(:a_value)         { FactoryGirl.create(:check_value,template:a_template,boolean_name:"是否铜鼓",date_name:"整改日期",float_name:"搞毛",int_name:"测试")}
    specify do
      cc = a_template.check_categories
      cv = a_template.check_value
      a_template.destroy
      cc.each  do |c|
        CheckCategory.find_by_id(c.id).should be_nil
      end
      CheckValue.find_by_id(cv.id).should be_nil
    end
  end
end
