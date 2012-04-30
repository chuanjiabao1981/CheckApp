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
  let!(:a_report_2)      {FactoryGirl.create(:report_with_some_records,
                                              organization:a_zone_org,
                                              template:a_template,
                                              committer:a_zone_org.worker,
                                              status:"finished")}
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
        page.should have_link('新建报告',href:new_organization_report_path(a_zone_org,format: :mobile))
        a_zone_org.reports.each do |report|
          if report.supervisor_report?
            page.should_not have_link(report.template.name,href:check_categories_report_path(report,format: :mobile))
          elsif report.worker_report?
            page.should have_link(report.template.name,href:check_categories_report_path(report,format: :mobile))
            if report.status_is_new?
              page.should have_selector('td',text:'进行中')
            elsif report.status_is_finished?
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
      end
      describe "report status 是new" do
        before { click_link a_report_1.template.name }
        specify do
          #TODO::owner才能有编辑和修改功能
          page.should have_link('编辑',href:edit_report_path(a_report_1,format: :mobile))
          page.should have_link('删除',href:report_path(a_report_1))
          page.should have_selector('li',text:a_report_1.reporter_name)

          a_report_1.template.check_categories.each do |cc|
            page.should have_selector('td',text:cc.check_points.size().to_s)
            page.should have_selector('td',text:ReportRecord.where('check_category_id=? and report_id=?',cc.id,a_report_1.id).size().to_s)
            page.should have_link(cc.category,href:check_category_check_point_reports_report_path(a_report_1.id,cc.id,format: :mobile))
          end
        end
      end
      describe "report status 是finished" do
        before do
          a_report_1.status ='finished'
          a_report_1.save
          click_link a_report_1.template.name
        end
        specify do
          page.should_not have_link('编辑',href:edit_report_path(a_report_1,format: :mobile))
          page.should_not have_link('删除',href:report_path(a_report_1))
        end
      end
    end
    describe "正常访问 一个status为new的report的某一个category下全部的checkpoints" do
      before do
        sign_in a_zone_worker
        visit worker_organization_reports_path(a_zone_org,format: :mobile)
        click_link a_report_1.template.name
        click_link a_report_1.template.check_categories[2].category
      end
      specify do
        a_report_1.should be_status_is_new
        a_report_1.template.check_categories[2].check_points.each do |cp|
          r = ReportRecord.where('report_id=? and check_point_id=?',a_report_1.id,cp.id).first
          if r.nil?
            page.should have_selector('td',text:cp.content)
            page.should have_link('新建',href:new_report_record_path(a_report_1,cp,format: :mobile))
          elsif
            page.should have_selector('td',text:cp.content)
            page.should have_link('编辑',href:edit_report_record_path(r,format: :mobile))
          end
        end
      end
    end
    describe "正常访问 一个status为finished的report的某一个category下的全部checkpoints" do
      before do
        sign_in a_zone_worker
        visit check_category_check_point_reports_report_path(a_report_2,a_report_2.template.check_categories[2])
      end
      specify do
        a_report_2.should be_valid
        a_report_2.should be_status_is_finished
        a_report_2.template.check_categories[2].check_points.each do |cp|
          r = ReportRecord.where('report_id=? and check_point_id=?',a_report_2.id,cp.id).first
          if r.nil?
            page.should have_selector('td',text:cp.content)
            page.should have_selector('td',text:'未完成')
          elsif 
            page.should have_selector('td',text:cp.content)
            page.should have_link('查看',href:report_record_path(r,format: :mobile))
          end
        end
      end
    end
    describe "new a report" do
      before do
        sign_in(a_zone_worker)
        visit worker_organization_reports_path(a_zone_org,format: :mobile)
        click_link '新建报告'
      end
      describe "正常信息" do
        before do
          fill_in '提交人员',with: '马李了'
          select a_zone_admin.templates.first.name, from:'报告类型'
        end
        it "增加一个" do
          #TODO::基本元素的存在
          expect { click_button '新增'}.to change(Report,:count).by(1)
        end
      end
    end
    describe "edit a report" do
      before do
        sign_in a_zone_worker
        visit worker_organization_reports_path(a_zone_org,format: :mobile)
        click_link a_zone_org.reports.first.template.name
        click_link '编辑'
      end
      it '基本元素正常' do
        page.should have_selector('li',text:a_zone_org.reports.first.template.name)
      end
      describe "正常修改" do
        let(:new_reporter_name) {'了马李'}
        before do
          fill_in '提交人员',with:new_reporter_name
          click_button '保存'
        end
        it '修改提交者名称' do
          page.should have_selector('li',text:new_reporter_name)
        end
      end
    end
    describe "destroy a report" do
      before do
        sign_in a_zone_worker
        visit worker_organization_reports_path(a_zone_org,format: :mobile)
        click_link a_zone_org.reports.first.template.name
      end
      it "-1" do 
        expect { click_link '删除' }.to change(Report,:count).by(-1)
      end
      it "-9" do
        expect {click_link '删除'}.to change(ReportRecord,:count).by(-9)
      end
    end
  end
end
