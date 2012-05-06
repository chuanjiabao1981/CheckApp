#encoding:utf-8
require 'spec_helper'

describe ReportRecord do
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
  let!(:a_check_category)           {a_template.check_categories.create(category:"手续检查",des:"测试水平")}
  let!(:a_check_point)              {a_check_category.check_points.create(content:"是否建立了培训制度") }
  let!(:a_check_point_with_photo)   {a_check_category.check_points.create(content:"执照",can_photo:true)}


  let!(:b_template)          { b_zone_admin.templates.create(
                                                            name:'b_template',
                                                            for_supervisor:true,
                                                            for_worker:true,
                                                            check_value_attributes:{boolean_name:"b2",date_name:"dd"}
                                                           )
                            }
                                                                
  let!(:a_organization)      { a_zone.organizations.create(name:"a_org",phone:"222333",contact:"马科长",address:"十八最") }
  let!(:b_organization)      { b_zone.organizations.create(name:"b_org",phone:"222333",contact:"马科长",address:"十八最") }



  before do 
    @a_supervisor_zone_relation = a_zone.zone_supervisor_relations.create(zone_supervisor_id:a_zone_supervisor.id)
    @report = a_organization.reports.build({reporter_name:"dddd",template_id:a_template.id})#,committer:a_zone_supervisor)
    @report.committer = a_zone_supervisor
    @report.status = 'new'
    @report.save
    @report_record = @report.report_records.build(check_point_id:a_check_point.id,boolean_value:false)
    @report_record.check_category_id = a_check_point.check_category.id
    @report_record_with_photo        = FactoryGirl.create(:report_record_with_photo,
                                                           report:@report,
                                                           check_category:a_check_point_with_photo.check_category,
                                                           check_point:a_check_point_with_photo)
    #@report_record_with_9m_photo   = FactoryGirl.build(:report_record_with_9m_photo,
                                                           #report:@report,
                                                           #check_category:a_check_point_with_photo.check_category,
                                                           #check_point:a_check_point_with_photo)
  end
  subject {@report_record}

  it {should be_valid }


  it {should respond_to(:report) }
  it {should respond_to(:check_point_id) }
  it {should respond_to(:check_point)}
  it {should respond_to(:boolean_value)}
  it {should respond_to(:int_value)}
  it {should respond_to(:float_value)}
  it {should respond_to(:date_value)}
  it {should respond_to(:text_value)}
  it {should respond_to(:photo_path)}
  it {should respond_to(:video_path)}
  it {should respond_to(:check_category)}
  it {should respond_to(:check_category_id)}
  
  describe "没有check_point是非法的" do
    before do
      @report_record.check_point_id = '202'
    end
    it {should_not be_valid }
  end
  describe "测试photo path" do
    specify do
      @report_record_with_photo.should be_valid
      file_path = @report_record_with_photo.photo_path.current_path
      File.exist?(file_path).should == true
      @report_record_with_photo.destroy
      File.exist?(file_path).should == false
    end
  end
  #describe "测试photo大小" do
  # specify do
  #   @report_record_with_9m_photo.save
  #   @report_record_with_9m_photo.photo_path = File.open(File.join(Rails.root, 'spec', 'support', 'report_record', 'photo', '1_1M.jpg'))
  #   @report_record_with_9m_photo.save 
  # end
  #end
  
end
