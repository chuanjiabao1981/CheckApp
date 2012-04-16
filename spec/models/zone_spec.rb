#encoding:utf-8
require 'spec_helper'


def normal_test
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
describe Zone do
  let(:the_site_admin)      { FactoryGirl.create(:site_admin) }
  let(:a_zone_admin)        { the_site_admin.zone_admins.create(name:"testme",password:"foobar",password_confirmation:"foobar") }

  before  { @a_zone = a_zone_admin.zones.build(name:"他么",des:"12333444") }
  subject { @a_zone }

  it {should respond_to(:name) }
  it {should respond_to(:des)  }
  it {should respond_to(:zone_admin_id) }
  it {should respond_to(:zone_admin)  }
  it {should respond_to(:organizations) }
  it {should respond_to(:zone_supervisor_relations) }
  it {should respond_to(:zone_supervisors) }
  it {should be_valid }
  
  its(:zone_admin) {should == a_zone_admin }

  normal_test

  describe "Zone删除 解除和zone_supervisor的关系" do
    before do
        @a_zone.save
        @a_zone_supervisor = @a_zone.zone_supervisors.create(name:"testme2",password:"foobar",password_confirmation:"foobar")
        @a_zone.zone_supervisor_relations.create(zone_supervisor_id:@a_zone_supervisor.id)
    end
    specify do
      ZoneSupervisorRelation.find_by_zone_id(@a_zone.id).should_not be_nil
      @a_zone.destroy
      ZoneSupervisorRelation.find_by_zone_id(@a_zone.id).should be_nil
    end
  end

  describe "Zone删除 ORG同样被删除" do
    before do
      @a_zone.save
      @a_org = @a_zone.organizations.create(name:"2233333")
    end
    specify do
      Organization.find_by_id(@a_org.id).should_not be_nil
      @a_zone.destroy
      Organization.find_by_id(@a_org.id).should be_nil
    end
  end

end
