#encoding:utf-8
require 'spec_helper'


def normal_test
  describe "错误测试" do
    describe "name长度太长" do
      before { @org.name = "你好"*300 }
      it { should_not be_valid }
    end
    describe "phone 太长" do
      before {@org.phone = "3"*300 }
      it {should_not be_valid }
    end
    describe "address 太长" do
      before {@org.address ="3"*300 }
      it {should_not be_valid }
    end
    describe "contact 太长" do
      before {@org.contact = "3"*300 }
      it { should_not be_valid}
    end
    describe "名字为空" do
      before {@org.name = "" } 
      it {should_not be_valid }
    end
    describe "联系人为空" do
      before {@org.contact = "" }
      it { should_not be_valid }
    end
    describe "地址为空" do
      before {@org.address = "" }
      it {should_not be_valid }
    end
  end
end

describe Organization do
  let(:the_site_admin)      { FactoryGirl.create(:site_admin) }
  let(:a_zone_admin)        { the_site_admin.zone_admins.create(name:"testme",password:"foobar",password_confirmation:"foobar") }
  let(:a_zone)              { a_zone_admin.zones.create(name:"123",des:"3333") }
  let(:a_zone_supervisor)   { a_zone_admin.zone_supervisors.create(name:"222",password:"foobar",password_confirmation:"foobar") }

  before { @org = a_zone.organizations.build(name:"12344",phone:"222333",contact:"马科长",address:"十八最") }
  subject {@org}

  it {should be_valid }
  it {should respond_to(:name) }
  it {should respond_to(:address) }
  it {should respond_to(:phone) }
  it {should respond_to(:contact) }
  it {should respond_to(:zone) }
  it {should respond_to(:worker) }
  it {should respond_to(:checker) }

  it {should respond_to(:reports) }

  describe "关联测试" do

    #let!(:a_checker) {FactoryGirl.create(:checker,organizations:@org) }
    let!(:a_checker) {@org.create_checker(name:"a_checker",password:"foobar",password_confirmation:"foobar") }
    let!(:a_worker)  {@org.create_worker(name:"a_worker",password:"foobar",password_confirmation:"foobar") }
    before  {@org.destroy}
    specify do
      Worker.find_by_id(a_worker.id).should be_nil
      Checker.find_by_id(a_checker.id).should be_nil
    end
  end

  describe "nest attribute 测试" do
    before do
      @org = a_zone.organizations.build(name:"a_zone_org",phone:"222333-44",contact:"王先生",address:"北京市",
                                        checker_attributes:{name:"a_org_cheker",password:"foobar",password_confirmation:"foobar"},
                                        worker_attributes:{name:"a_org_woker",password:"foobar",password_confirmation:"foobar"}
                                       )
    end
    it { should be_valid }
    
    specify do
      @org.checker should be_valid
      @org.worker  should be_valid
    end
  end
end
