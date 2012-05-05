#encoding:utf-8
require 'spec_helper'

describe "ReportRecords" do
  let(:the_site_admin){FactoryGirl.create(:site_admin_with_two_zone_admin)}
  let(:a_zone_admin)  {the_site_admin.zone_admins.first }
  let(:b_zone_admin)  {the_site_admin.zone_admins.last  }
  let(:a_zone)        {a_zone_admin.zones.first}
  let(:a_zone_supervisor) { a_zone_admin.zone_supervisors.first }
  let(:b_zone_supervisor) { a_zone_admin.zone_supervisors.last  }
  let(:a_zone_org_1)      {a_zone.organizations.first}
  let(:a_zone_org_2)      {a_zone.organizations.last}
  let(:a_zone_org_1_worker)   {a_zone_org_1.worker}
  let(:a_zone_org_1_checker)  {a_zone_org_1.checker}
  let(:a_zone_org_2_worker)   {a_zone_org_2.worker}
  let(:a_zone_org_2_checker)  {a_zone_org_2.checker}
  let!(:a_template)      {FactoryGirl.create(:template_with_all_required,zone_admin:a_zone_admin,for_worker:true,for_supervisor:true)}
  let!(:a_zone_org_1_report_1)      {FactoryGirl.create(:report_with_some_records,
                                              organization:a_zone_org_1,
                                              template:a_template,
                                              committer:a_zone_org_1.worker,
                                              status:"new")}
  let!(:a_zone_org_1_report_1_a_record) {
                                          a_zone_org_1_report_1.report_records.first
                                        }
  let!(:a_zone_org_1_report_2)      {FactoryGirl.create(:report_with_some_records,
                                              organization:a_zone_org_1,
                                              template:a_template,
                                              committer:a_zone_org_1.worker,
                                              status:"finished")}
  let!(:a_zone_org_1_report_3)      {FactoryGirl.create(:report_with_all_records,
                                                         organization:a_zone_org_1,
                                                         template:a_template,
                                                         committer:a_zone_org_1.worker,
                                                         status:"finished")}

  let!(:a_zone_org_1_report_4)      {FactoryGirl.create(:report_with_some_records,
                                                         organization:a_zone_org_1,
                                                         template:a_template,
                                                         committer:a_zone_supervisor,
                                                         status:"finished")}
  let!(:a_zone_org_1_report_5)      {FactoryGirl.create(:report_with_all_records,
                                                         organization:a_zone_org_1,
                                                         template:a_template,
                                                         committer:a_zone_supervisor,
                                                         status:"finished")}
  let!(:a_zone_org_1_report_6)      {FactoryGirl.create(:report_with_some_records,
                                                         organization:a_zone_org_1,
                                                         template:a_template,
                                                         committer:a_zone_supervisor,
                                                         status:"new")}
  let!(:a_zone_org_1_report_6_a_record) {
                                            a_zone_org_1_report_6.report_records.first
                                        }


  before do
    a_zone_org_1_worker.password  = 'foobar'
    a_zone_org_1_checker.password = 'foobar'
    a_zone_org_2_checker.password = 'foobar'
    a_zone_supervisor.password   = 'foobar'
    b_zone_supervisor.password   = 'foobar'
    a_zone_admin.password        = 'foobar'
    b_zone_admin.password        = 'foobar'
    the_site_admin.password      = 'foobar'
  end

  shared_examples_for "report record common view" do
    before do
      test_record.check_point.can_photo = true
      test_record.check_point.can_video = true
      test_record.check_point.save
      sign_in user
      visit report_record_path(test_record,format: :mobile)
    end
    specify do
      #print page.html
      page.should have_link('返回',href:check_category_check_point_reports_report_path(test_record.report_id,test_record.check_category_id))
      page.should have_selector('td',text:test_record.check_point.content)
      if test_template.check_value.has_int_name?
        #puts test_record.get_int_value
        page.has_css?('td',text:test_template.check_value.int_name).should == true
        page.has_css?('td',text:test_record.get_int_value).should == true
      end
      if test_template.check_value.has_date_name?
        #puts test_record.get_date_value
        page.has_css?('td',text:test_template.check_value.date_name).should == true
        page.has_css?('td',text:test_record.get_date_value).should == true
      end
      if test_template.check_value.has_text_name?
        #puts test_record.get_text_value
        page.has_css?('td',text:test_template.check_value.text_name).should == true
        page.has_css?('td',text:test_record.get_text_value).should == true
      end
      if test_template.check_value.has_boolean_name?
        #puts test_record.get_boolean_value
        page.has_css?('td',text:test_template.check_value.boolean_name).should == true
        page.has_css?('td',text:test_record.get_boolean_value).should == true
      end
      if test_template.check_value.has_float_name?
        #puts test_record.get_float_value
        page.has_css?('td',text:test_template.check_value.float_name).should == true
        page.has_css?('td',text:test_record.get_float_value).should == true
      end
      if test_record.check_point.can_photo
        page.has_css?('td',text:'图像').should == true
        image_url          = test_record.get_photo_path
        image_css_selector = "img[src=\"#{image_url}\"]"
        page.has_css?(image_css_selector).should == true
      end
      if test_record.check_point.can_video
        page.has_css?('td',text:'视频').should == true
        video_url           = test_record.get_video_path
        video_css_selector  = "video[src=\"#{video_url}\"]"
        page.has_css?(video_css_selector).should == true
      end
    end
  end
  describe "siginin worker visit worker report record " do
    it_should_behave_like "report record common view" do
      let!(:test_record)      {a_zone_org_1_report_1_a_record}
      let!(:test_template)    {a_template}
      let!(:user)             {a_zone_org_1_worker}
    end
  end
  describe "siginin supervisor visit supervisor report record "do
    before do
      a_zone_org_1.zone.zone_supervisors<<a_zone_supervisor
    end
    it_should_behave_like "report record common view" do
      let!(:test_record)    {a_zone_org_1_report_6_a_record}
      let!(:test_template)  {a_template}
      let!(:user)           {a_zone_supervisor}
    end
  end
end
