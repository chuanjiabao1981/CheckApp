#encoding:utf-8
require 'spec_helper'


def validate_test
  describe "机构必须存在" do
    before { @report.organization_id = 20111203 }
    it {should_not be_valid }
  end
  describe "report,template,organizations " do
    describe " template 和 organization 通用 valid关系" do
      describe " report的模板必须是由 org 所在zone的管理员（zone_admin）创建的" do
        before {@report.template_id = b_template.id }
        it {should_not be_valid}
      end
      describe "给一个错误的状态" do
        before {@report.status="111111" }
        it {should_not be_valid }
      end
    end
    describe " supervisor_report 的valid关系" do  
      describe "supervisor 只能用supervisor的摸板" do
        before do
          @report.template.for_supervisor = false
          @report.template.for_worker     = true
        end
        it {should_not be_valid}
      end
      describe " a_zone_supervisor和对应的zone解除关系，已经存储的report还是合法的" do
        ###这佯作主要主要是考虑zone_supervisor可能从负责一个zone迁移到另外一个zone
        ###即便是这种情况，report应该还是合法的
        before do
          @a_supervisor_zone_relation.destroy
        end
        it { should be_valid }
      end
    end
    describe " worker_report 的 valid关系" do
      describe "worker 只能用worker的摸板" do
        before do
          @worker_report = b_worker.reports.build(reporter_name:"b_worker",organization_id:b_organization.id,template_id:b_template.id)
          @worker_report.status = 'reject'
          @worker_report.name ="督察报告-2012-33344"
        end
        specify do
          @worker_report.should be_valid
          @worker_report.template.for_supervisor = true
          @worker_report.template.for_worker     = false
          @worker_report.should_not be_valid
        end
        describe "worker 只能提供他所对应的org的report" do
          before do
            @worker_report.organization_id = a_organization.id
          end
          specify do
            @worker_report.should_not be_valid 
          end
        end
      end
    end
  end

end
describe Report do
  let!(:the_site_admin)      { FactoryGirl.create(:site_admin) }
  let!(:a_zone_admin)        { the_site_admin.zone_admins.create(name:"testme",password:"foobar",password_confirmation:"foobar") }
  let!(:b_zone_admin)        { the_site_admin.zone_admins.create(name:"bzone_admin",password:"foobar",password_confirmation:"foobar") }
  let!(:a_zone)              { a_zone_admin.zones.create(name:"a_zone",des:"a_zone_des") }
  let!(:b_zone)              { b_zone_admin.zones.create(name:"b_zone",des:"b_zone_des")}
  let!(:a_zone_supervisor)   { a_zone_admin.zone_supervisors.create(name:"a_zone_sup",password:"foobar",password_confirmation:"foobar") }
  let!(:b_zone_supervisor)   { b_zone_admin.zone_supervisors.create(name:"b_zone_sup",password:"foobar",password_confirmation:"foobar") }
  let!(:a_template)          { a_zone_admin.templates.create(
                                                            name:'a_template',
                                                            for_supervisor:true,
                                                            for_worker:false,
                                                            check_value_attributes:{boolean_name:"b1",date_name:"d1"}
                                                          )
                            }
  let!(:b_template)          { b_zone_admin.templates.create(
                                                            name:'b_template',
                                                            for_supervisor:true,
                                                            for_worker:true,
                                                            check_value_attributes:{boolean_name:"b2",date_name:"dd"}
                                                           )
                            }
                                                                
  let!(:a_organization)      { a_zone.organizations.build(name:"a_org",phone:"222333",contact:"马科长",address:"十八最") }
  let!(:b_organization)      { b_zone.organizations.build(name:"b_org",phone:"222333",contact:"马科长",address:"十八最") }

  let!(:a_worker)            { FactoryGirl.create(:worker,organization:a_organization) }
  let!(:b_worker)            { FactoryGirl.create(:worker,organization:b_organization,name:"b_worker") }


  before do 
    @a_supervisor_zone_relation = a_zone.zone_supervisor_relations.create(zone_supervisor_id:a_zone_supervisor.id)
    @report = a_zone_supervisor.reports.build(reporter_name:"dddd",organization_id:a_organization.id,template_id:a_template.id)
    @report.name    = "自查报告_模板名称_2012_"
    @report.status = 'new'
  end
  subject {@report }
  it {should be_valid }

  it {should respond_to(:name)                }  
  it {should respond_to(:reporter_name)       }
  it {should respond_to(:template)            }
  it {should respond_to(:organization)        }
  it {should respond_to(:template_id)         }
  it {should respond_to(:organization_id)     }
  validate_test
  
  describe "normal 测试" do
    describe "reportor 名字过长" do
      before {@report.reporter_name = "5"*255 } 
      it { should_not be_valid }
    end
    describe "reportor name必须存在" do
      before {@report.reporter_name = "" }
      it { should_not be_valid }
    end
    describe "report 必须要有状态" do
      before {@report.status = "" }
      it { should_not be_valid }
    end
    
  end

  

end
