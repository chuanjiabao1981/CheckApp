#encoding:utf-8
# == Schema Information
#
# Table name: check_points
#
#  id                :integer         not null, primary key
#  content           :text
#  check_category_id :integer
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#

require 'spec_helper'

describe CheckPoint do
  let(:the_site_admin)        { FactoryGirl.create(:site_admin) }
  let(:the_template)          { FactoryGirl.create(:for_supervisor,zone_admin:the_site_admin) }
  let(:a_check_category)      { FactoryGirl.create(:check_category,template:the_template)}
  before { @a_check_point  = a_check_category.check_points.build(content:"是否建立了培训制度") }
  subject{ @a_check_point }
  it {should respond_to(:content) }
  it {should respond_to(:check_category_id) }
  it {should respond_to(:check_category)}
  it {should respond_to(:can_video)}
  it {should respond_to(:can_photo)}
  it {should be_valid }

  describe "错误数据" do
    describe "content太长" do
      before {@a_check_point.content = "你" * 2000}
      it { should_not be_valid }
    end
    describe "category_id 是nil" do
      before {@a_check_point.check_category_id = nil}
      it { should_not be_valid }
    end
    describe "content为空" do
      before {@a_check_point.content=""}
      it{should_not be_valid}
    end
  end

end
