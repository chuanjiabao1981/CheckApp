#encoding:utf-8
require 'spec_helper'


def login_worker_visit_organization_reports
  specify do
    a_zone_org_1_report_1.should be_valid
    a_template.should be_valid
    page.should have_link('新建自检报告',href:new_organization_report_path(a_zone_org_1,format: :mobile))
    a_zone_org_1.reports.each do |report|
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

def fail_visit_organization_report_mobile
  describe "非org worker访问" do
    before do
      sign_in a_zone_org_2_worker
      get worker_organization_reports_path(a_zone_org_1_worker,format: :mobile)
    end
    specify do
      response.should redirect_to root_path
    end
  end
  describe "非登陆用户" do
    before do
      get worker_organization_reports_path(a_zone_org_1_worker,format: :mobile)
    end
    specify do
      response.should redirect_to root_path
    end
  end
  describe "zone supervisor 登陆  看不到新建自查报告" do
    before do
      a_zone_org_1.zone.zone_supervisors<<a_zone_supervisor
      sign_in a_zone_supervisor
      visit worker_organization_reports_path(a_zone_org_1,format: :mobile)
    end
    specify do
      page.should_not have_link('新建自检报告',href:new_organization_report_path(a_zone_org_1,format: :mobile))
      n = 0
      a_zone_org_1.reports.each do |report|
        if report.supervisor_report?
          page.should_not have_link(report.template.name,href:check_categories_report_path(report,format: :mobile))
        elsif report.worker_report?
          if report.status_is_new?
            page.should_not have_selector('td',text:'进行中')
            page.should_not have_link(report.template.name,href:check_categories_report_path(report,format: :mobile))
          elsif report.status_is_finished?
            n = n+1
            page.should have_link(report.template.name,href:check_categories_report_path(report,format: :mobile))
            page.should have_selector('td',text:'通过')
          end
        end
      end
      n.should == 2
    end
  end
  describe "非负责的zone supervisor 无法访问" do
    before do
      sign_in a_zone_supervisor
      get worker_organization_reports_path(a_zone_org_1,format: :mobile)
    end
    specify do
      response.should redirect_to root_path
    end
  end
  describe "非负责的zone_admin无法访问" do
    before do
      sign_in b_zone_admin
      get worker_organization_reports_path(a_zone_org_1,format: :mobile)
    end
    specify do
      response.should redirect_to root_path
    end
  end

end

def login_worker_visit_organization_reports_category
  before do
    sign_in a_zone_org_1_worker
    visit worker_organization_reports_path(a_zone_org_1,format: :mobile)
  end
  describe "report status 是new" do
    before { click_link a_zone_org_1_report_1.template.name }
    specify do
      page.should have_link('编辑',href:edit_report_path(a_zone_org_1_report_1,format: :mobile))
      page.should have_link('删除',href:report_path(a_zone_org_1_report_1))
      page.should have_selector('li',text:a_zone_org_1_report_1.reporter_name)

      a_zone_org_1_report_1.template.check_categories.each do |cc|
        page.should have_selector('td',text:cc.check_points.size().to_s)
        page.should have_selector('td',text:ReportRecord.where('check_category_id=? and report_id=?',cc.id,a_zone_org_1_report_1.id).size().to_s)
        page.should have_link(cc.category,href:check_category_check_point_reports_report_path(a_zone_org_1_report_1.id,cc.id,format: :mobile))
      end
    end
  end
  describe "report status 是finished" do
    before do
      a_zone_org_1_report_1.status ='finished'
      a_zone_org_1_report_1.save
      click_link a_zone_org_1_report_1.template.name
    end
    specify do
      page.should_not have_link('编辑',href:edit_report_path(a_zone_org_1_report_1,format: :mobile))
      page.should_not have_link('删除',href:report_path(a_zone_org_1_report_1))
    end
  end

end
def fail_visit_organization_reports_category
  describe "非org worker不能访问report的category" do
    before do
      sign_in a_zone_org_2_worker
      get check_categories_report_path(a_zone_org_1_report_1,format: :mobile)
    end
    specify do
      response.should redirect_to root_path
    end
  end
  describe "负责的zone_supervisor 只能看不能编辑和访问" do
    before do
      a_zone_org_1.zone.zone_supervisors<<a_zone_supervisor
      sign_in a_zone_supervisor
      visit check_categories_report_path(a_zone_org_1_report_1,format: :mobile)
    end
    specify do
      page.should_not have_link('编辑',href:edit_report_path(a_zone_org_1_report_1,format: :mobile))
      page.should_not have_link('删除',href:report_path(a_zone_org_1_report_1))
      page.should have_selector('li',text:a_zone_org_1_report_1.reporter_name)
    end
  end
  describe "非负责的zone_supervisor不能访问" do
    before do
      sign_in a_zone_supervisor
      get check_categories_report_path(a_zone_org_1_report_1,format: :mobile)
    end
    specify do
      response.should redirect_to root_path
    end
  end
end

def normal_visit_report_a_category_all_check_points
  #zone_supervisor看不到status 为new的report
  #describe "zone_supervisor 正常访问 一个status为new的report的某一个category下全部的checkpoints" do
  #end
  describe "正常访问 一个status为new的report的某一个category下全部的checkpoints" do
    before do
      sign_in a_zone_org_1_worker
      visit worker_organization_reports_path(a_zone_org_1,format: :mobile)
      click_link a_zone_org_1_report_1.template.name
      click_link a_zone_org_1_report_1.template.check_categories[2].category
    end
    specify do
      a_zone_org_1_report_1.should be_status_is_new
      a_zone_org_1_report_1.template.check_categories[2].check_points.each do |cp|
        r = ReportRecord.where('report_id=? and check_point_id=?',a_zone_org_1_report_1.id,cp.id).first
        if r.nil?
          page.should have_selector('td',text:cp.content)
          page.should have_link('新建',href:new_report_record_path(a_zone_org_1_report_1,cp,format: :mobile))
        elsif
          page.should have_selector('td',text:cp.content)
          page.should have_link('编辑',href:edit_report_record_path(r,format: :mobile))
        end
      end
    end
  end
  describe "正常访问 一个status为finished的report的某一个category下的全部checkpoints" do
    before do
      sign_in a_zone_org_1_worker
      visit check_category_check_point_reports_report_path(a_zone_org_1_report_2,a_zone_org_1_report_2.template.check_categories[2])
    end
    specify do
      a_zone_org_1_report_2.should be_valid
      a_zone_org_1_report_2.should be_status_is_finished
      a_zone_org_1_report_2.template.check_categories[2].check_points.each do |cp|
        r = ReportRecord.where('report_id=? and check_point_id=?',a_zone_org_1_report_2.id,cp.id).first
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
  describe "zone_supervisor正常访问 一个status为finished的report的某一个category下的全部checkpoints" do
    before do
      a_zone_org_1.zone.zone_supervisors<<a_zone_supervisor
      sign_in a_zone_supervisor
      visit check_category_check_point_reports_report_path(a_zone_org_1_report_2,a_zone_org_1_report_2.template.check_categories[2])
    end
    specify do
      a_zone_org_1_report_2.should be_valid
      a_zone_org_1_report_2.should be_status_is_finished
      a_zone_org_1_report_2.template.check_categories[2].check_points.each do |cp|
        r = ReportRecord.where('report_id=? and check_point_id=?',a_zone_org_1_report_2.id,cp.id).first
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

end

def visit_new_a_organization_report
    describe "new a report" do
      before do
        sign_in(a_zone_org_1_worker)
        visit worker_organization_reports_path(a_zone_org_1,format: :mobile)
        click_link '新建自检报告'
      end
      describe "正常信息" do
        before do
          fill_in '提交人员',with: '马李了'
          select a_zone_admin.templates.first.name, from:'报告类型'
        end
        it "增加一个" do
          expect { click_button '新增'}.to change(Report,:count).by(1)
        end
      end
      describe "非正常信息" do
        describe "提交空信息" do
          it '不变' do
            expect { click_button '新增'}.not_to change(Report,:count)
          end
        end
      end
    end
    describe "未登陆用户 new report get" do
      before {get new_organization_report_path(a_zone_org_1,format: :mobile)}
      specify {response.should redirect_to root_path }
    end
    describe "未登陆用户 create report post" do
      before {post organization_reports_path(a_zone_org_1)}
      specify{response.should redirect_to root_path }
    end
    describe "登陆的非org worker get" do
      before do
        sign_in a_zone_org_2_worker
        get new_organization_report_path(a_zone_org_1,format: :mobile) 
      end
      specify { response.should redirect_to root_path}
    end
    describe "登陆的非org worker post" do
      before do
        sign_in a_zone_org_2_worker
        post organization_reports_path(a_zone_org_1)
      end
      specify { response.should redirect_to root_path }
    end
    describe "登陆worker 访问不存在的org" do
      before do
        sign_in a_zone_org_2_worker
        get new_organization_report_path(1203,format: :mobile)
      end
      specify { response.should redirect_to root_path }
    end
end
def visit_edit_report 
  describe "非report committer (worker)不能修改页面" do
    before do
      sign_in a_zone_org_2_worker
      get edit_report_path(a_zone_org_1.reports.first,format: :mobile)
    end
    specify do  
      response.should redirect_to root_path
    end
  end
  describe "非report的committer（supervisor）不能访问修改页面" do
    before do
      a_zone_org_1.zone.zone_supervisors<<a_zone_supervisor
      sign_in a_zone_supervisor
      get edit_report_path(a_zone_org_1.reports.first,format: :mobile)
    end
    specify do
      response.should redirect_to root_path
    end
  end
  describe "edit a report" do
    before do
      sign_in a_zone_org_1_worker
      visit worker_organization_reports_path(a_zone_org_1,format: :mobile)
      click_link a_zone_org_1.reports.first.template.name
      click_link '编辑'
    end
    it '基本元素正常' do
      page.should have_selector('li',text:a_zone_org_1.reports.first.template.name)
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

end
def destroy_worker_report
  describe "destroy a report" do
    before do
      sign_in a_zone_org_1_worker
      visit worker_organization_reports_path(a_zone_org_1,format: :mobile)
      click_link a_zone_org_1.reports.first.template.name
    end
    it "-1" do 
      expect { click_link '删除' }.to change(Report,:count).by(-1)
    end
    it "-9" do
      expect {click_link '删除'}.to change(ReportRecord,:count).by(-9)
    end
  end
  describe "destroy a finished report" do
    before do
      sign_in a_zone_org_1_worker
      visit check_categories_report_path(a_zone_org_1_report_2)
    end
    specify do
      page.should_not have_link('删除',href:report_path(a_zone_org_1_report_2))
    end
    it 'finished report 不能被worker删除' do
      expect { delete report_path(a_zone_org_1_report_2) }.not_to change(Report,:count) 
    end
  end
end

def normal_supervisor_report_index
  describe "访问org的report列表页" do
    before do
      sign_in a_zone_supervisor 
      visit zone_supervisor_organization_reports_path(a_zone_org_1,format: :mobile)
    end
    specify do
      finished_supervisor_report_num = 0
      new_supervisor_report_num      = 0
      all_worker_report_num          = 0
      page.should have_link('新建督察报告',href:new_organization_report_path(a_zone_org_1,format: :mobile))
      a_zone_org_1.reports.each do |r|
        if r.supervisor_report?
          page.should have_link(r.template.name,href:check_categories_report_path(r,format: :mobile)) 
          if r.status_is_new?
            page.should have_selector('td',text:'进行中')
            new_supervisor_report_num = new_supervisor_report_num + 1
          end
          if r.status_is_finished?
            page.should have_selector('td',text:'通过')
            finished_supervisor_report_num = finished_supervisor_report_num + 1
          end
        elsif r.worker_report?
          all_worker_report_num = all_worker_report_num + 1
          page.should_not have_link(r.template.name,href:check_categories_report_path(r,format: :mobile))
        end
      end         
      #puts finished_supervisor_report_num,new_supervisor_report_num,all_worker_report_num
      finished_supervisor_report_num.should == 2
      new_supervisor_report_num.should == 1
      all_worker_report_num == 3
    end
  end
  describe "访问一个org的status为new的report的category列表页" do
    before do
      sign_in a_zone_supervisor
      visit check_categories_report_path(a_zone_org_1_report_6)
    end
    specify do
      page.should have_link('编辑',href:edit_report_path(a_zone_org_1_report_6,format: :mobile))
      page.should have_link('删除',href:report_path(a_zone_org_1_report_6))
      page.should have_selector('li',text:a_zone_org_1_report_6.reporter_name)

      a_zone_org_1_report_6.template.check_categories.each do |cc|
        page.should have_selector('td',text:cc.check_points.size().to_s)
        page.should have_selector('td',text:ReportRecord.where('check_category_id=? and report_id=?',cc.id,a_zone_org_1_report_6.id).size().to_s)
        page.should have_link(cc.category,href:check_category_check_point_reports_report_path(a_zone_org_1_report_6.id,cc.id,format: :mobile))
      end
    end
  end
  describe "访问一个org的status为finished的report的category列表页" do
    before do
      sign_in a_zone_supervisor
      visit check_categories_report_path(a_zone_org_1_report_4)
    end
    specify do
      page.should_not have_link('编辑',href:edit_report_path(a_zone_org_1_report_4,format: :mobile))
      page.should_not have_link('删除',href:report_path(a_zone_org_1_report_4))
      page.should have_selector('li',text:a_zone_org_1_report_4.reporter_name)
      
      a_zone_org_1_report_4.template.check_categories.each do |cc|
        page.should have_selector('td',text:cc.check_points.size().to_s)
        page.should have_selector('td',text:ReportRecord.where('check_category_id=? and report_id=?',cc.id,a_zone_org_1_report_4.id).size().to_s)
        page.should have_link(cc.category,href:check_category_check_point_reports_report_path(a_zone_org_1_report_4.id,cc.id,format: :mobile))
      end   
    end
  end
  describe "访问一个org的status为new的report一个category下的checkpoints列表页" do
    before do
      sign_in a_zone_supervisor
      visit check_categories_report_path(a_zone_org_1_report_6)
      click_link a_zone_org_1_report_6.template.check_categories[2].category      
    end
    specify do
      a_zone_org_1_report_6.should be_status_is_new
      a_zone_org_1_report_6.should be_supervisor_report
      new_check_point = 0
      finished_check_point = 0
      
      a_zone_org_1_report_6.template.check_categories[2].check_points.each do |cp|
        rr = ReportRecord.where('report_id=? and check_point_id =?',a_zone_org_1_report_6.id,cp.id).first
        page.should have_selector('td',text:cp.content)
        if rr.nil?
          new_check_point = new_check_point + 1
          page.should have_link('新建',href:new_report_record_path(a_zone_org_1_report_6,cp,format: :mobile))
        else
          finished_check_point = finished_check_point + 1
          page.should have_link('编辑',href:edit_report_record_path(rr,format: :mobile))
        end
      end
      new_check_point.should == 1
      finished_check_point.should == 4
    end
  end
  describe "访问一个org的status为finished的report一个category下的checkpoints列表页" do
    before do
      sign_in a_zone_supervisor
      visit check_categories_report_path(a_zone_org_1_report_4)
      click_link a_zone_org_1_report_4.template.check_categories[2].category      
    end
    specify do
      a_zone_org_1_report_4.should be_status_is_finished
      a_zone_org_1_report_4.should be_supervisor_report
      new_check_point = 0
      finished_check_point = 0
      
      a_zone_org_1_report_4.template.check_categories[2].check_points.each do |cp|
        rr = ReportRecord.where('report_id=? and check_point_id =?',a_zone_org_1_report_4.id,cp.id).first
        page.should have_selector('td',text:cp.content)
        if rr.nil?
          new_check_point = new_check_point + 1
          page.should have_selector('td',text:'未完成')
          #page.should have_link('新建',href:new_report_record_path(a_zone_org_1_report_4,cp,format: :mobile))
        else
          finished_check_point = finished_check_point + 1
          page.should have_link('查看',href:report_record_path(rr,format: :mobile))
        end
      end
      new_check_point.should == 1
      finished_check_point.should == 4
    end
  end

end

def normal_supervisor_report_new
  describe "new zone_supervisor report" do
    let(:new_report_reportor_name) {'马了了'}
    before do
      sign_in a_zone_supervisor
      visit zone_supervisor_organization_reports_path(a_zone_org_1,format: :mobile)
      click_link '新建督察报告'
      fill_in '提交人员',with: new_report_reportor_name
      select a_zone_admin.templates.first.name, from:'报告类型'
    end
    it "+1" do
      expect {click_button '新增'}.to change(Report,:count).by(1)
    end
    it "页面变化" do
      click_button '新增'
      page.should have_selector('li',text:new_report_reportor_name)
    end
  end
end

def normal_supervisor_report_edit
  describe "edit supervisor report status is new" do
    let(:new_report_reportor_name) {'了了马'}
    before do
      sign_in a_zone_supervisor
      visit check_categories_report_path(a_zone_org_1_report_6,format: :mobile)
    end
    specify do
      a_zone_org_1_report_6.should be_status_is_new
      click_link '编辑'
      fill_in '提交人员',with:new_report_reportor_name
      click_button '保存'
      page.should have_selector('li',text:new_report_reportor_name)
    end
  end
  describe "edit supervisor report status is finished" do
    before do
      sign_in a_zone_supervisor
      visit check_categories_report_path(a_zone_org_1_report_4,format: :mobile)
    end
    specify do
      a_zone_org_1_report_4.should be_status_is_finished
      a_zone_org_1_report_4.should be_supervisor_report
      page.should_not have_link('编辑',href:edit_report_path(a_zone_org_1_report_4))
    end
  end

end
def normal_supervisor_report_destroy
  describe "destroy zone_supervisor report status is new" do
    before do
      sign_in a_zone_supervisor
      visit check_categories_report_path(a_zone_org_1_report_6)
    end
    specify do
      a_zone_org_1_report_6.should be_supervisor_report
      a_zone_org_1_report_6.should be_status_is_new
    end
    it "-1" do
      expect {click_link '删除'}.to change(Report,:count).by(-1)
    end
  end
  describe "destroy zone_supervisor report status is finished" do
    before do
      sign_in a_zone_supervisor
      visit check_categories_report_path(a_zone_org_1_report_4)
    end
    specify do
      a_zone_org_1_report_4.should be_supervisor_report
      a_zone_org_1_report_4.should be_status_is_finished
      page.should_not have_link('删除',href:report_path(a_zone_org_1_report_4))
    end
  end

end
def unnormal_supervisor_report_index
  describe "zone_supervisor 报告的异常测试" do
    describe "zone supervisor index view test" do
      describe "非负责的 zone supervisor 看不到" do
        before do
          sign_in b_zone_supervisor
          get zone_supervisor_organization_reports_path(a_zone_org_1,format: :mobile)
        end
        specify do
          response.should redirect_to root_path
        end
      end
      describe "org的worker 看到,但是没创建 " do
        before do
          sign_in a_zone_org_1_worker
          visit zone_supervisor_organization_reports_path(a_zone_org_1,format: :mobile)
        end
        specify do
          page.should_not have_link('新建督察报告',href:new_organization_report_path(a_zone_org_1))
        end
      end
    end
  end
end
def unnormal_supervisor_report_edit
  describe "只有report的创建者才能调用report的edit" do
    describe "status 为new [功能] get" do
      before do
        sign_in b_zone_supervisor
        get edit_report_path(a_zone_org_1_report_6,format: :mobile)
      end
      specify do
        a_zone_org_1_report_6.should be_supervisor_report
        a_zone_org_1_report_6.should be_status_is_new
        response.should redirect_to root_path
      end
    end
    describe "status 为finished [功能] get" do
      before do
        sign_in a_zone_supervisor
        get edit_report_path(a_zone_org_1_report_4,format: :mobile)
      end
      specify do
        a_zone_org_1_report_4.should be_supervisor_report
        a_zone_org_1_report_4.should be_status_is_finished
        a_zone_org_1_report_4.committer == a_zone_supervisor
        response.should redirect_to root_path
      end
    end
    describe "status 为new[功能]put" do
      before do
        sign_in b_zone_supervisor
        put report_path(a_zone_org_1_report_6,format: :mobile)
      end
      specify do
        a_zone_org_1_report_6.should be_supervisor_report
        a_zone_org_1_report_6.should be_status_is_new
        response.should redirect_to root_path
      end
    end
    describe "status 为finished[功能]put" do
      before do
        sign_in a_zone_supervisor
        put report_path(a_zone_org_1_report_4,format: :mobile)
      end
      specify do
        a_zone_org_1_report_4.should be_supervisor_report
        a_zone_org_1_report_4.should be_status_is_finished
        a_zone_org_1_report_4.committer == a_zone_supervisor
        response.should redirect_to root_path
      end
    end
  end
end
def unnormal_supervisor_report_new
  describe "非worker 和 supervisor 都不能调用new 和 create" do
    describe "zone_admin" do
      before do
        sign_in a_zone_admin
        get new_organization_report_path(a_zone_org_1)
      end
      specify do
        response.should redirect_to root_path
      end
    end
  end
end
def unnormal_supervisor_report_destroy
  describe "destroy zone supervisor status new 非owner" do
    before do
      sign_in b_zone_supervisor
      delete report_path(a_zone_org_1_report_6)
    end
    specify do
      a_zone_org_1_report_6.should be_supervisor_report
      a_zone_org_1_report_6.should be_status_is_new
      a_zone_org_1_report_6.committer.should_not == b_zone_supervisor
      response.should redirect_to root_path
    end
  end
  describe "describe zone supervisor status finished owner" do
    before do
      sign_in a_zone_supervisor
      delete report_path(a_zone_org_1_report_4)
    end
    specify do
      a_zone_org_1_report_4.should be_supervisor_report
      a_zone_org_1_report_4.should be_status_is_finished
      a_zone_org_1_report_6.committer.should == a_zone_supervisor
      response.should redirect_to root_path
    end
  end

end
describe "Reports" do
  let(:the_site_admin){FactoryGirl.create(:site_admin_with_two_zone_admin)}
  let(:a_zone_admin)  {the_site_admin.zone_admins.first }
  let(:b_zone_admin)  {the_site_admin.zone_admins.last  }
  let(:a_zone)        {a_zone_admin.zones.first}
  let(:a_zone_supervisor) { a_zone_admin.zone_supervisors.first }
  let(:b_zone_supervisor) { a_zone_admin.zone_supervisors.last  }
  let(:a_zone_org_1)      {a_zone.organizations.first}
  let(:a_zone_org_2)      {a_zone.organizations.last}
  let(:a_zone_org_1_worker)   {a_zone_org_1.worker}
  let(:a_zone_org_2_worker)   {a_zone_org_2.worker}
  let!(:a_template)      {FactoryGirl.create(:template_with_all_required,zone_admin:a_zone_admin,for_worker:true,for_supervisor:true)}
  let!(:a_zone_org_1_report_1)      {FactoryGirl.create(:report_with_some_records,
                                              organization:a_zone_org_1,
                                              template:a_template,
                                              committer:a_zone_org_1.worker,
                                              status:"new")}
  let!(:a_zone_org_1_report_2)      {FactoryGirl.create(:report_with_some_records,
                                              organization:a_zone_org_1,
                                              template:a_template,
                                              committer:a_zone_org_1.worker,
                                              status:"finished")}
  let!(:a_zone_org_1_report_3)      {FactoryGirl.create(:report,organization:a_zone_org_1,template:a_template,committer:a_zone_org_1.worker,status:"finished")}

  let!(:a_zone_org_1_report_4)      {FactoryGirl.create(:report_with_some_records,
                                                         organization:a_zone_org_1,
                                                         template:a_template,
                                                         committer:a_zone_supervisor,
                                                         status:"finished")}
  let!(:a_zone_org_1_report_5)      {FactoryGirl.create(:report,organization:a_zone_org_1,template:a_template,committer:a_zone_supervisor,status:"finished")}
  let!(:a_zone_org_1_report_6)      {FactoryGirl.create(:report_with_some_records,
                                                         organization:a_zone_org_1,
                                                         template:a_template,
                                                         committer:a_zone_supervisor,
                                                         status:"new")}


  before do
    a_zone_org_1_worker.password = 'foobar'
    a_zone_supervisor.password   = 'foobar'
    b_zone_supervisor.password   = 'foobar'
    a_zone_admin.password        = 'foobar'
    the_site_admin.password      = 'foobar'
  end


  describe "worker 报告" do
    fail_visit_organization_report_mobile
    describe "worker 正常访问 自查报告列表" do
      before do
        sign_in a_zone_org_1_worker
        visit worker_organization_reports_path(a_zone_org_1,format: :mobile)
      end
      login_worker_visit_organization_reports
    end
    describe "访问 report的category" do
      fail_visit_organization_reports_category
      login_worker_visit_organization_reports_category
    end
    normal_visit_report_a_category_all_check_points
    visit_new_a_organization_report
    visit_edit_report
    destroy_worker_report
    describe "zone_supervisor 报告" do
      before do
        a_zone_org_1.zone.zone_supervisors<<a_zone_supervisor
      end
      normal_supervisor_report_index
      normal_supervisor_report_new
      normal_supervisor_report_edit
      normal_supervisor_report_destroy
      
    end
    unnormal_supervisor_report_index
    unnormal_supervisor_report_edit
    unnormal_supervisor_report_new
    unnormal_supervisor_report_destroy
    describe "zone_supervisor index html报告" do
      before do
        sign_in a_zone_admin
        visit zone_supervisor_organization_reports_path(a_zone_org_1)
      end
      specify do
        new_report_num        = 0
        finished_report_num   = 0
        worker_report_num     = 0
        a_zone_org_1.reports.each do |report|
          if report.supervisor_report?
            page.should have_link(report.template.name,href:report_detail_report_path(report))
            if report.status_is_new?
              page.should have_selector('td',text:'进行中') 
              new_report_num = new_report_num + 1
            elsif report.status_is_finished?
              page.should have_selector('td',text:'通过')
              finished_report_num = finished_report_num + 1
            else
              "1".should == "2"
            end
          elsif report.worker_report?
            page.should_not have_link(report.template.name,href:report_detail_report_path(report))
            worker_report_num = worker_report_num + 1
          end
        end
        new_report_num.should == 1
        finished_report_num.should == 2
        worker_report_num.should == 3
      end
    end
    describe "zone_supervisor detail html报告" do
      before do
        sign_in a_zone_admin
        visit report_detail_report_path(a_zone_org_1_report_6)
      end
      specify do
        #TODO::视频和图片
        #page.should have_css('th[style*="display:none"]',text:"dddd")
        #rowspan="4"
        #page.should have_css("th[rowspan=\"#{rowspan}\"]",text:"dddd")
        test_template = a_zone_org_1_report_6.template
        if test_template.check_value.has_boolean_name?
          page.should have_selector('th',text:test_template.check_value.boolean_name)
        else
          page.should have_css('th[style*="display:none"]',text:test_template.check_value.boolean_name)
        end 
        if test_template.check_value.has_int_name?
          page.should have_selector('th',text:test_template.check_value.int_name)
        else
          page.should have_css('th[style*="display:none"]',text:test_template.check_value.int_name)
        end
        if test_template.check_value.has_float_name?
          page.should have_selector('th',text:test_template.check_value.float_name)
        else
          page.should have_css('th[style*="display:none"]',text:test_template.check_value.float_name)
        end
        if test_template.check_value.has_date_name?
          page.should have_selector('th',text:test_template.check_value.date_name)
        else
          page.should have_css('th[style*="display:none"]',text:test_template.check_value.date_name)
        end
        if test_template.check_value.has_text_name?
          page.should have_selector('th',text:test_template.check_value.text_name)
        else
          page.should have_css('th[style*="display:none"]',text:test_template.check_value.text_name)
        end
        #page.should have_selector('th','图片')
        #page.should have_selector('th','视频')

        a_zone_org_1_report_6.template.check_categories.each do |cc|
          cp_num = cc.check_points.size().to_s
          page.should have_css("th[rowspan=\"#{cp_num}\"]",text:cc.category)
          cc.check_points.each do |cp|
            page.should have_selector("td",text:cp.content)
            rr = a_zone_org_1_report_6.get_report_record_by_check_point_id(cp.id)
            if rr.nil?
              css_selector = "td[style*=\"display:none\"]"
              value        = "未完成"
            else
              css_selector = "td"
              if test_template.check_value.has_boolean_name?
                value        = rr.get_boolean_value
              else
                value        = "未配置"
              end
              if test_template.check_value.has_int_name?
                value       = rr.get_int_value
              else
                value       = "未配置"
              end
              if test_template.check_value.has_float_name?
                value       = rr.get_boolean_value
              else
                value       = "未配置"
              end
              if test_template.check_value.has_date_name?
                value       = rr.get_date_value
              else
                value       = "未配置"
              end
              if test_template.check_value.has_text_name?
                value       = rr.get_text_value
              else
                value       = "未配置"
              end
            end
            page.should have_css(css_selector,text:value)
          end
        end
      end
    end
  end
end
