#encoding:utf-8
require 'spec_helper'

describe "Reports" do
  let(:the_site_admin){FactoryGirl.create(:site_admin_with_two_zone_admin)}
  let(:a_zone_admin)  {the_site_admin.zone_admins.first }
  let(:a_zone)        {a_zone_admin.zones.first}
  let(:a_zone_supervisor) { a_zone_admin.zone_supervisors.first }
  let(:a_zone_org)    {a_zone.organizations.first}
  let(:a_zone_worker) {a_zone_org.worker}
  let!(:a_template)      {FactoryGirl.create(:template_with_all_required,zone_admin:a_zone_admin,for_worker:true,for_supervisor:true)}
  let!(:a_report_1)      {FactoryGirl.create(:report_with_some_records,
                                              organization:a_zone_org,
                                              template:a_template,
                                              committer:a_zone_org.worker,
                                              status:"new")}
  let!(:a_report_2)      {FactoryGirl.create(:report,organization:a_zone_org,template:a_template,committer:a_zone_org.worker,status:"finished")}
  let!(:a_report_3)      {FactoryGirl.create(:report,organization:a_zone_org,template:a_template,committer:a_zone_org.worker,status:"finished")}

  let!(:a_report_4)      {FactoryGirl.create(:report,organization:a_zone_org,template:a_template,committer:a_zone_supervisor,status:"finished")}
  let!(:a_report_5)      {FactoryGirl.create(:report,organization:a_zone_org,template:a_template,committer:a_zone_supervisor,status:"finished")}
  let!(:a_report_6)      {FactoryGirl.create(:report,organization:a_zone_org,template:a_template,committer:a_zone_supervisor,status:"new")}


  before do
    a_zone_worker.password = 'foobar'
  end


  describe "worker 报告" do
    describe "正常访问 自查报告列表" do
      before do
        sign_in a_zone_worker
        visit worker_organization_reports_path(a_zone_org,format: :mobile)
      end
      specify do
        a_report_1.should be_valid
        a_template.should be_valid
        a_zone_org.reports.each do |report|
          if report.supervisor_report?
            page.should_not have_link(report.template.name,href:check_categories_report_path(report,format: :mobile))
          elsif report.worker_report?
            page.should have_link(report.template.name,href:check_categories_report_path(report,format: :mobile))
            if report.is_new?
              page.should have_selector('td',text:'进行中')
            elsif report.is_finished?
              page.should have_selector('td',text:'通过')
            end
          end
        end
      end
    end
    ##TODO::编辑提交者名称
    describe "正常访问 report的category" do
      before do
        sign_in a_zone_worker
        visit worker_organization_reports_path(a_zone_org,format: :mobile)
        click_link a_report_1.template.name
      end
      specify do
        a_report_1.template.check_categories.each do |cc|
          page.should have_selector('td',text:cc.check_points.size().to_s)
          page.should have_selector('td',text:ReportRecord.where('check_category_id=? and report_id=?',cc.id,a_report_1.id).size().to_s)
          page.should have_link(cc.category,href:check_category_check_point_reports_report_path(a_report_1.id,cc.id,format: :mobile))
        end
      end
    end
    describe "正常访问 report的某一个category下全部的checkpoints" do
      before do
        sign_in a_zone_worker
        visit worker_organization_reports_path(a_zone_org,format: :mobile)
        click_link a_report_1.template.name
        click_link a_report_1.template.check_categories.last.category
      end
      specify do
        a_report_1.template.check_categories.last.check_points.each do |cp|
          #if a_report_1.is_finished?
          #  r = ReportRecord.where('report_id=? and check_point_id=?',a_report_1.id,cp.id)
          #  if r.nil?
          #    page.should have_selector('td',text:cp.content)
          #    page.should have_selector('td',text:'未完成')
          #  elsif
          #    page.should have_link('td',text:cp.describe)
          #    page.should have_link('查看',href:record_path(ReportRecord.where('report_id=? and check_point_id=?',a_report_1.id,cp.id)[0].ida))
          #  end
          #end
          if a_report_1.is_new? 
            r = ReportRecord.where('report_id=? and check_point_id=?',a_report_1.id,cp.id)
            if r.nil?
              page.should have_selector('td',text:cp.content)
              page.should have_link('新建',href:new_report_record_path(a_report_1,cp))
            elsif
              page.should have_selector('td',text:cp.content)
              page.should have_link('编辑',href:edit_report_record_path(r))
            end
          end
        end
      end
    end
  end
end
