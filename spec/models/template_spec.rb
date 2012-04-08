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

describe Template do
  let(:the_site_admin) { FactoryGirl.create(:site_admin)}
  before { @template=the_site_admin.templates.build(name:'test_template',for_supervisor:true,for_worker:false)}
  subject { @template }
  it { should be_valid}
  it { should respond_to(:name) }
  it { should respond_to(:for_supervisor) }
  it { should respond_to(:for_worker)}
  it { should respond_to(:admin) }
  it { should respond_to(:check_categories) }
  it { should be_for_supervisor}
  it { should_not be_for_worker }
  it { should respond_to(:check_value) }
  it { should_not be_can_video }
  it { should_not be_can_photo}

  describe "不合法的情况" do
    describe "名字为空" do
      before { @template.name = " " }
      it { should_not be_valid }
    end
    describe "admin_id为空" do
      before { @template.admin_id = nil }
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
