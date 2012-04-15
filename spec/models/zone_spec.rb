#encoding:utf-8
require 'spec_helper'

describe Zone do
  let!(:the_site_admin) { FactoryGirl.create(:site_admin) }
  let!(:a_zone_admin)   { FactoryGirl.create(:zone_admin,name:'a_zone_admin') }
  before { @a_zone = a_zone_admin.zones.build(name:"他么",des:"12333444") }
  subject { @a_zone }
  it {should respond_to(:name) }
  it {should respond_to(:des)  }
  it {should respond_to(:zone_admin_id) }
  it {should respond_to(:zone_admin)  }
  it {should respond_to(:organizations) }
  it {should be_valid }
  
  its(:zone_admin) {should == a_zone_admin }

  describe "必须要有zone_admin_id" do
    before { @a_zone.zone_admin_id = nil }
    it { should_not be_valid }
  end

  describe "必须要有名字" do
    before { @a_zone.name =" " }
    it { should_not be_valid }
  end
  describe "输入要有限制" do
    describe "名字太长" do
      before {@a_zone.name = "r"*500 }
      it { should_not be_valid }
    end
    describe "描述太长" do
      before {@a_zone.des = "r"*500 }
      it { should_not be_valid }
    end
  end
  describe "删除" do
    before do
      @a_zone.save
      @a_zone.organizations.create(name:"123")
      @a_zone.organizations.create(name:"234")
    end
    specify do
      t = @a_zone.organizations
      @a_zone.destroy
      t.each do |o|
        Organization.find_by_id(o.id).should be_nil
      end
    end
  end
end
