#encoding:utf-8
require 'spec_helper'


def login_worker_visit_organization_reports
  specify do
    a_zone_org_1_report_1.should be_valid
    a_template.should be_valid
    page.should have_link('新建自检报告',href:new_organization_report_path(a_zone_org_1,format: :mobile))
    page.should have_selector('li',text:a_zone_org_1_report_1.organization.name)
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
            # 由于策略发生了修改，为完成的报告允许被看到，所以注释掉如下两行
            # page.should_not have_selector('td',text:'进行中')
            # page.should_not have_link(report.template.name,href:check_categories_report_path(report,format: :mobile))
          elsif report.status_is_finished?
            n = n+1
            page.should have_link(report.template.name,href:check_categories_report_path(report,format: :mobile))
            page.should have_selector('td',text:'通过')
          end
        end
      end
      n.should == 3
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
    # before { click_link a_zone_org_1_report_1.template.name }
    before {      page.find("tr:nth-child(6)").find_link(a_zone_org_1_report_1.template.name).click } 
    specify do
      # print page.html
      # page.find("tr:nth-child(6)").find_link(a_zone_org_1_report_1.template.name)
      page.should have_link('编辑',href:edit_report_path(a_zone_org_1_report_1,format: :mobile))
      page.should have_link('删除',href:report_path(a_zone_org_1_report_1))
      page.should have_selector('td',text:a_zone_org_1_report_1.reporter_name)

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
      page.should have_selector('td',text:a_zone_org_1_report_1.reporter_name)
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
      # click_link a_zone_org_1_report_1.template.name
      page.find("tr:nth-child(6)").find_link(a_zone_org_1_report_1.template.name).click
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
          # print page.html
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
      page.find("tr:nth-child(6)").find_link(a_zone_org_1_report_1.template.name).click 
      # click_link a_zone_org_1.reports.first.template.name
      click_link '编辑'
    end
    # it '基本元素正常' do
      # page.should have_selector('td',text:a_zone_org_1.reports.first.template.name)
    # end
    describe "正常修改" do
      let(:new_reporter_name) {'了马李'}
      before do
        fill_in '提交者',with:new_reporter_name
        click_button '保存'
      end
      it '修改提交者名称' do
        page.should have_selector('td',text:new_reporter_name)
      end
    end
  end

end
def destroy_worker_report
  describe "destroy a report" do
    before do
      sign_in a_zone_org_1_worker
      visit worker_organization_reports_path(a_zone_org_1,format: :mobile)
      page.find("tr:nth-child(6)").find_link(a_zone_org_1_report_1.template.name).click
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
      finished_supervisor_report_num.should == 3
      new_supervisor_report_num.should == 2
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
      page.should have_selector('td',text:a_zone_org_1_report_6.reporter_name)

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
      page.should have_selector('td',text:a_zone_org_1_report_4.reporter_name)
      
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
      page.should have_selector('td',text:new_report_reportor_name)
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
      fill_in '提交者',with:new_report_reportor_name
      click_button '保存'
      page.should have_selector('td',text:new_report_reportor_name)
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
def test_report_detail_page(test_template,test_report,see_other_action)

  #specify do
    #TODO::视频和图片
    no_set_text         = "未设置"
    no_complete_text    = "未完成" 
    #print page.html
    #print "--------------------------------------------------------------"
    #test_template       = a_zone_org_1_report_6.template
    #test_report         = a_zone_org_1_report_6
    check_points_num    = 0
    CheckCategory.where('template_id=?',test_template.id).each do |cc|
      check_points_num  +=cc.check_points.size
    end

    finished_check_points_num = ReportRecord.find_all_by_report_id(test_report.id).size
    page.should have_selector('th',text:"报告类型")
    page.should have_selector('td',text:test_template.name)
    page.should have_selector('th',text:"检查点个数")
    page.should have_selector('td',text:"#{check_points_num}个")
    page.should have_selector('th',text:"已完成检查点")
    page.should have_selector('td',text:"#{finished_check_points_num}个")
    page.should have_selector('th',text:"提交人")
    page.should have_selector('td',text:"#{test_report.reporter_name}")
    page.should have_selector('th',text:"提交时间")
    tt = I18n.localize(test_report.created_at,format: :long)
    page.should have_selector('td',text:"#{tt}")
    if see_other_action
      if test_report.status_is_new?
        page.has_css?('input[value="审核通过"]').should == true
      else
        page.has_css?('input[value="重新修改"]').should == true
      end
      page.should have_link('删除',href:report_path(test_report))
    else
      page.has_css?('input[value="审核通过"]').should == false
      page.has_css?('input[value="重新修改"]').should == false
      page.should_not have_selector('删除',href:report_path(test_report))
    end

    
    if test_template.check_value.has_boolean_name?
      page.should have_selector('th',text:test_template.check_value.boolean_name)
    else
      page.should have_css('th[style*="display:none"]',text:no_set_text)
    end 
    if test_template.check_value.has_int_name?
      page.should have_selector('th',text:test_template.check_value.int_name)
    else
      page.should have_css('th[style*="display:none"]',text:no_set_text)
    end
    if test_template.check_value.has_float_name?
      page.should have_selector('th',text:test_template.check_value.float_name)
    else
      page.should have_css('th[style*="display:none"]',text:no_set_text)
    end
    if test_template.check_value.has_date_name?
      page.should have_selector('th',text:test_template.check_value.date_name)
    else
      page.should have_css('th[style*="display:none"]',text:no_set_text)
    end
    if test_template.check_value.has_text_name?
      page.should have_selector('th',text:test_template.check_value.text_name)
    else
      page.should have_css('th[style*="display:none"]',text:no_set_text)
    end
    test_report.template.check_categories.each do |cc|
      cp_num = cc.check_points.size().to_s
      next if cp_num == "0"
      page.should have_css("th[rowspan=\"#{cp_num}\"]",text:cc.category)
      cc.check_points.each do |cp|
        page.should have_selector("td",text:cp.content)
        rr = test_report.get_report_record_by_check_point_id(cp.id)

        if cp.can_photo and not rr.nil?
          css_selector = "a[href=\"#{rr.media_infos.first.photo_path}\"]"
          page.has_css?(css_selector).should == true
        end
        if test_template.check_value.has_boolean_name?
          css_selector = "td"
          if rr.nil?
            value        = no_complete_text
          else
            value        = rr.get_boolean_value
          end
        else
          css_selector = "td[style*=\"display:none\"]"
          value        = no_set_text 
        end
        page.should have_css(css_selector,text:value)

        if test_template.check_value.has_int_name?
          css_selector    = "td"
          if rr.nil?
            value           = no_complete_text
          else 
            value           = rr.get_int_value
          end
        else
          css_selector  = "td[style*=\"display:none\"]"
          value         = no_set_text
        end
        page.should have_css(css_selector,text:value)

        if test_template.check_value.has_float_name?
          css_selector  = "td"
          if rr.nil?
            value       = no_complete_text
          else
            value       = rr.get_float_value
          end
        else
          value         = no_set_text 
        end
        page.should have_css(css_selector,text:value)

        if test_template.check_value.has_date_name?
          css_selector  = "td"
          if rr.nil?
            value       = no_complete_text
          else
            value       = rr.get_date_value
          end
        else
          value         = no_set_text
        end
        page.should have_css(css_selector,text:value)

        if test_template.check_value.has_text_name?
          css_selector  = "td"
          if rr.nil?
            value       = no_complete_text
          else
            value       = rr.get_text_value
          end
        else
          value         = no_set_text
        end
        page.should have_css(css_selector,text:value)
      end
    end
  #end

end
def normal_supervisor_report_detail
    describe "zone_admin登陆访问supervisor report detail html报告" do
      before do
        sign_in a_zone_admin
        visit report_detail_report_path(a_zone_org_1_report_6)
      end
      specify do
        test_report_detail_page(a_zone_org_1_report_6.template,a_zone_org_1_report_6,true)
      end
    end
    describe "zone_admin登陆访问supervisor unormal report detail html报告" do
      before do
        sign_in a_zone_admin
        visit report_detail_report_path(a_zone_org_1_supervisor_report_with_unormal_template_status_is_new,true)
      end
      specify do
        test_report_detail_page(a_zone_org_1_supervisor_report_with_unormal_template_status_is_new.template,
                                a_zone_org_1_supervisor_report_with_unormal_template_status_is_new,
                                true)
      end
    end
    describe "site admin登陆访问supervisor report detail html报告" do
      before do
        sign_in the_site_admin
        visit report_detail_report_path(a_zone_org_1_report_6)
      end
      specify do
        test_report_detail_page(a_zone_org_1_report_6.template,a_zone_org_1_report_6,true)
      end
    end
    describe "checker登陆访问supervisor report detail html报告" do
      before do
        sign_in a_zone_org_1_checker
        visit report_detail_report_path(a_zone_org_1_report_4) 
      end
      specify do
        test_report_detail_page(a_zone_org_1_report_4.template,a_zone_org_1_report_4,false)
      end
    end

end
def test_supervisor_report_index(singin_user,test_org)

  new_report_num        = 0
  finished_report_num   = 0
  worker_report_num     = 0
  test_org.reports.each do |report|
    apath         = report_detail_report_path(report)
    css_selector = "a[href=\"#{apath}\"]"

    if report.supervisor_report?
      if singin_user.session.checker?
        if report.status_is_new?
          # page.has_css?(css_selector,text:report.template.name).should == false
        else
          page.has_css?(css_selector,text:report.template.name).should == true
        end
      else
        page.has_css?(css_selector,text:report.template.name).should == true
      end
      if report.status_is_new?
        if singin_user.session.checker?
          # page.should_not have_selector('td',text:'进行中')
        else
          page.should have_selector('td',text:'进行中') 
        end
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
  new_report_num.should == 2
  finished_report_num.should == 3
  worker_report_num.should == 5

end
def normal_supervisor_report_index_html
  describe "zone_admin 登陆访问一个org的supervisor report 的index html报告" do
    before do
      sign_in a_zone_admin
      visit zone_supervisor_organization_reports_path(a_zone_org_1)
    end
    specify do
      test_supervisor_report_index(a_zone_admin,a_zone_org_1)
    end
  end
  describe "site_admin 登陆访问一个org的supervisor report的index html报告" do
    before do
      sign_in the_site_admin
      visit zone_supervisor_organization_reports_path(a_zone_org_1)
    end
    specify do
      test_supervisor_report_index(the_site_admin,a_zone_org_1)
    end
  end
  describe "checker 登陆访问一个org的supervisor report的indexl html报告" do
    before do
      sign_in a_zone_org_1_checker
      visit zone_supervisor_organization_reports_path(a_zone_org_1)
    end
    specify do
      test_supervisor_report_index(a_zone_org_1_checker,a_zone_org_1)
    end
  end

end
def normal_supervisor_report_pass_and_reject
  describe "zone_admin 登陆 通过 supervisor report" do
    before do
      sign_in a_zone_admin
      a_zone_org_1_report_5.set_status_new
      a_zone_org_1_report_5.save
      visit report_detail_report_path(a_zone_org_1_report_5)
      click_button '审核通过'
    end
    specify do
      page.has_css?('input[value="重新修改"]').should == true
    end
  end
  describe "site_admin 登陆 通过 supervisor report" do
    before do
      sign_in the_site_admin
      a_zone_org_1_report_5.set_status_new
      a_zone_org_1_report_5.save
      visit report_detail_report_path(a_zone_org_1_report_5)
      click_button '审核通过'
    end
    specify do
      page.has_css?('input[value="重新修改"]').should == true
    end
  end
  describe "zone_admin 登陆 重新修改 supervisor report" do
    before do
      sign_in a_zone_admin
      visit report_detail_report_path(a_zone_org_1_report_5)
      click_button '重新修改'
    end
    specify do
      page.has_css?('input[value="审核通过"]').should == true
    end
  end
  describe "site_admin 登陆 重新修改 supervisor report" do
    before do
      sign_in the_site_admin
      visit report_detail_report_path(a_zone_org_1_report_5)
      click_button '重新修改'
    end
    specify do
      #print page.html
      page.has_css?('input[value="审核通过"]').should == true
    end
  end
end

def normal_supervisor_report_destroy_html
  describe "zone_admin 删除 supervisor report status is finished" do
    before do
      sign_in a_zone_admin 
      visit report_detail_report_path(a_zone_org_1_report_5)
    end
    it "-1" do
      expect{ click_link '删除'}.to change(Report,:count).by(-1)
    end
  end
  describe "zone_admin 删除 supervisor report status is new" do
    before do
      sign_in a_zone_admin 
      visit report_detail_report_path(a_zone_org_1_report_6)
    end
    it "-1" do
      expect{ click_link '删除'}.to change(Report,:count).by(-1)
    end
  end
  describe "site_admin 删除 supervisor_report status is finished" do
    before do
      sign_in the_site_admin 
      visit report_detail_report_path(a_zone_org_1_report_5)
    end
    it "-1" do
      expect{ click_link '删除'}.to change(Report,:count).by(-1)
    end
  end
  describe "site_admin 删除 supervisor_report status is new" do
    before do
      sign_in the_site_admin 
      visit report_detail_report_path(a_zone_org_1_report_6)
    end
    it "-1" do
      expect{ click_link '删除'}.to change(Report,:count).by(-1)
    end
  end
end
def unnormal_supervisor_report_destroy_html
  describe "非org所在zoneadmin 无法删除supervisor report" do
    before do
      sign_in b_zone_admin
      delete report_path(a_zone_org_1_report_6)
    end
    specify do
      response.should redirect_to root_path
    end
  end
  describe "chekcer 无法删除supervisor report" do
    before do
      sign_in a_zone_org_1_checker
      delete report_path(a_zone_org_1_report_6)
    end
    specify do
      response.should redirect_to root_path
    end
  end
  describe "worker 无法删除supervisor report" do
    before do
      sign_in a_zone_org_1_worker
      delete report_path(a_zone_org_1_report_5)
    end
    specify do
      response.should redirect_to root_path
    end
  end

end
def unnormal_supervisor_report_pass_and_reject
  shared_examples_for "unnormal reject or pass supervisor report" do
    specify do
      put pass_report_path(a_zone_org_1_report_6)
      response.should redirect_to root_path
    end
    specify do
      put reject_report_path(a_zone_org_1_report_5)
      response.should redirect_to root_path
    end
  end
  shared_examples_for "unnormal unfinished report can't pass" do
    it "has flash info" do
      #print page.html
      page.should have_selector('div.alert.alert-error', text: '报告未完成不能审核通过!')
      page.has_css?('input[value="审核通过"]').should == true
    end
  end
  describe "非org的zoneadmin 无法reject或者pass supervisor report" do
    before do
      sign_in b_zone_admin
    end
    it_should_behave_like "unnormal reject or pass supervisor report"
  end
  describe "checker无法rejct或者pass supervisor report" do
    before do
      sign_in a_zone_org_1_checker
    end
    it_should_behave_like "unnormal reject or pass supervisor report"
  end
  describe "zone_admin 登陆未完成的report不能通过" do
    before do
      sign_in a_zone_admin
      visit report_detail_report_path(a_zone_org_1_report_6)
      click_button '审核通过'
    end
    it_should_behave_like "unnormal unfinished report can't pass"
  end
  describe "zone_admin 登陆未完成的report不能通过" do
    before do
      sign_in the_site_admin
      visit report_detail_report_path(a_zone_org_1_report_6)
      click_button '审核通过'
    end
    it_should_behave_like "unnormal unfinished report can't pass"
  end
end
def unnormal_supervisor_report_detail 
  shared_examples_for "redirect_to root_path" do
    specify do
      response.should redirect_to root_path
    end
  end
  describe "非org的zoneadmin 无法访问supervisor report" do
    before do
      sign_in b_zone_admin
      get report_detail_report_path(a_zone_org_1_report_6)
    end
    it_should_behave_like "redirect_to root_path"
  end
  describe "非org的checker无法访问supervisor的report" do
    before do
      sign_in a_zone_org_2_checker   
      get report_detail_report_path(a_zone_org_1_report_5)
    end
    it_should_behave_like "redirect_to root_path"
  end
  describe "worker无法访问supervisor的report" do
    before do
      sign_in a_zone_org_1_worker
      get report_detail_report_path(a_zone_org_1_report_6)
    end
    it_should_behave_like "redirect_to root_path"
  end
end

def unnormal_supervisor_report_index_html
    describe "非org所在zone的zoneadmin 无法访问zonesupervisor index" do
      before do
        sign_in b_zone_admin
        get zone_supervisor_organization_reports_path(a_zone_org_1)
      end
      specify do
        response.should redirect_to root_path
      end
    end
    describe "非org的checker 无法访问zonesupervisor index" do
      before do
        sign_in a_zone_org_2_checker
        get zone_supervisor_organization_reports_path(a_zone_org_1)
      end
      specify do
        response.should redirect_to root_path
      end
    end
    describe "worker 无法访问zonesupervisor index" do
      before do
        sign_in a_zone_org_1_worker
        get zone_supervisor_organization_reports_path(a_zone_org_1)
      end
      specify do
        response.should redirect_to root_path
      end
    end
    describe "supervisor 无法访问zonesupervisor index" do
      before do
        sign_in a_zone_supervisor
        get zone_supervisor_organization_reports_path(a_zone_org_1)
      end
      specify do
        response.should redirect_to root_path
      end
    end
end
def normal_worker_report_index_html
  shared_examples_for "worker index html" do
    specify do
      #print page.html
      test_org.reports.each do |report| 
        apath           = report_detail_report_path(report)  
        css_selector    = "a[href=\"#{apath}\"]"
        if report.worker_report?
          if user.session.zone_admin?
            if report.status_is_new?
              # page.has_css?(css_selector,text:report.template.name).should == false
              # page.should_not have_selector('td',text:'进行中')
            else
              page.has_css?(css_selector,text:report.template.name).should == true
              page.should have_selector('td',text:'通过')
            end
          elsif user.session.checker? or user.session.site_admin?
            page.has_css?(css_selector,text:report.template.name).should == true
            page.should have_selector('td',text:'通过')
          end
        end
      end
    end
  end
  describe "a_zone admin sigin 访问worker report index html" do
    before do
      sign_in a_zone_admin
      visit worker_organization_reports_path(a_zone_org_1)
    end
    it_should_behave_like "worker index html" do
      let(:user) {a_zone_admin}
      let(:test_org) { a_zone_org_1 }
    end
  end
  describe "site admin sigin 访问worker report index html" do
    before do
      sign_in the_site_admin
      visit worker_organization_reports_path(a_zone_org_1)
    end
    it_should_behave_like "worker index html" do
      let(:user) {the_site_admin}
      let(:test_org) { a_zone_org_1 }
    end
  end
  describe "cheker sigin 访问worker report index html" do
    before do
      sign_in a_zone_org_1_checker
      visit worker_organization_reports_path(a_zone_org_1)
    end
    it_should_behave_like "worker index html" do
      let(:user) {a_zone_org_1_checker}
      let(:test_org) { a_zone_org_1 }
    end
  end

end
def normal_worker_report_detail
    describe "zone_admin登陆访问worker report detail html报告" do
      before do
        sign_in a_zone_admin
        visit report_detail_report_path(a_zone_org_1_report_1)
        #print page.html
      end
      specify do
        test_report_detail_page(a_zone_org_1_report_1.template,a_zone_org_1_report_1,false)
      end
    end
    describe "site admin登陆访问worker report detail html报告" do
      before do
        sign_in the_site_admin
        visit report_detail_report_path(a_zone_org_1_report_1)
      end
      specify do
        test_report_detail_page(a_zone_org_1_report_1.template,a_zone_org_1_report_1,true)
      end
    end
    describe "checker登陆访问worker report detail html报告" do
      before do
        sign_in a_zone_org_1_checker
        visit report_detail_report_path(a_zone_org_1_report_3) 
        #print page.html
      end
      specify do
        test_report_detail_page(a_zone_org_1_report_3.template,a_zone_org_1_report_3,true)
      end
    end
    describe "checker登陆访问worker report detail html报告" do
      before do
        sign_in a_zone_org_1_checker
        visit report_detail_report_path(a_zone_org_1_worker_report_with_unormal_template_status_is_new)
      end
      specify do
        test_report_detail_page(a_zone_org_1_worker_report_with_unormal_template_status_is_new.template,
                                a_zone_org_1_worker_report_with_unormal_template_status_is_new,true)
      end
    end

end
def normal_worker_report_pass_and_reject
  describe "checker 登陆 通过 worker report" do
    before do
      sign_in a_zone_org_1_checker
      a_zone_org_1_report_3.set_status_new
      a_zone_org_1_report_3.save
      visit report_detail_report_path(a_zone_org_1_report_3)
      click_button '审核通过'
    end
    specify do
      page.has_css?('input[value="重新修改"]').should == true
    end
  end
  describe "site_admin 登陆 通过 worker report" do
    before do
      sign_in the_site_admin
      a_zone_org_1_report_3.set_status_new
      a_zone_org_1_report_3.save
      visit report_detail_report_path(a_zone_org_1_report_3)
      click_button '审核通过'
    end
    specify do
      page.has_css?('input[value="重新修改"]').should == true
    end
  end
  describe "checker 登陆 重新修改 worker report" do
    before do
      sign_in a_zone_org_1_checker
      visit report_detail_report_path(a_zone_org_1_report_3)
      click_button '重新修改'
    end
    specify do
      page.has_css?('input[value="审核通过"]').should == true
    end
  end
  describe "site_admin 登陆 重新修改 worker report" do
    before do
      sign_in the_site_admin
      visit report_detail_report_path(a_zone_org_1_report_3)
      click_button '重新修改'
    end
    specify do
      #print page.html
      page.has_css?('input[value="审核通过"]').should == true
    end
  end
end
def normal_worker_report_destroy_html
  describe "checker 删除 worker  report status is finished" do
    before do
      sign_in a_zone_org_1_checker
      visit report_detail_report_path(a_zone_org_1_report_3)
    end
    it "-1" do
      expect{ click_link '删除'}.to change(Report,:count).by(-1)
    end
  end
  describe "checker 删除 worker report status is new" do
    before do
      sign_in a_zone_org_1_checker
      visit report_detail_report_path(a_zone_org_1_report_1)
    end
    it "-1" do
      expect{ click_link '删除'}.to change(Report,:count).by(-1)
    end
  end
  describe "site_admin 删除 worker_report status is finished" do
    before do
      sign_in the_site_admin 
      visit report_detail_report_path(a_zone_org_1_report_3)
    end
    it "-1" do
      expect{ click_link '删除'}.to change(Report,:count).by(-1)
    end
  end
  describe "site_admin 删除 worker_report status is new" do
    before do
      sign_in the_site_admin 
      visit report_detail_report_path(a_zone_org_1_report_1)
    end
    it "-1" do
      expect{ click_link '删除'}.to change(Report,:count).by(-1)
    end
  end
end

def unnormal_worker_report_destroy_html
  describe "非org的checker 无法删除worker report" do
    before do
      sign_in a_zone_org_2_checker
      delete report_path(a_zone_org_1_report_1)
    end
    specify do
      response.should redirect_to root_path
      a_zone_org_1_report_1.should be_worker_report
    end
  end
  describe "zone admin 无法删除worker report" do
    before do
      sign_in a_zone_admin
      delete report_path(a_zone_org_1_report_1)
    end
    specify do
      response.should redirect_to root_path
    end
  end
  describe "supervisor 无法删除worker report" do
    before do
      a_zone_org_1.zone.zone_supervisors<<a_zone_supervisor
      sign_in a_zone_supervisor
      delete report_path(a_zone_org_1_report_3)
    end
    specify do
      response.should redirect_to root_path
    end
  end

end
def unnormal_worker_report_detail 
  shared_examples_for "worker redirect_to root_path" do
    specify do
      response.should redirect_to root_path
    end
  end
  describe "非org的zoneadmin 无法访问worker report" do
    before do
      sign_in b_zone_admin
      get report_detail_report_path(a_zone_org_1_report_1)
    end
    it_should_behave_like "worker redirect_to root_path"
  end
  describe "非org的checker无法访问worker report" do
    before do
      sign_in a_zone_org_2_checker   
      get report_detail_report_path(a_zone_org_1_report_1)
    end
    it_should_behave_like "worker redirect_to root_path"
  end
  describe "supervisor 无法访问worker的report的html" do
    before do
      a_zone_org_1.zone.zone_supervisors<<a_zone_supervisor
      sign_in a_zone_supervisor
      get report_detail_report_path(a_zone_org_1_report_1)
    end
    it_should_behave_like "worker redirect_to root_path"
  end
end
def unnormal_worker_report_pass_and_reject
  shared_examples_for "unnormal reject or pass worker report" do
    specify do
      put pass_report_path(a_zone_org_1_report_1)
      response.should redirect_to root_path
    end
    specify do
      put reject_report_path(a_zone_org_1_report_3)
      response.should redirect_to root_path
    end
  end
  shared_examples_for "unnormal unfinished worker report can't pass" do
    it "has flash info" do
      #print page.html
      page.should have_selector('div.alert.alert-error', text: '报告未完成不能审核通过!')
      page.has_css?('input[value="审核通过"]').should == true
    end
  end
  describe "org的zoneadmin 无法reject或者pass worker report ." do
    before do
      sign_in a_zone_admin
    end
    it_should_behave_like "unnormal reject or pass worker report"
  end
  describe "非org的checker无法rejct或者pass worker report" do
    before do
      sign_in a_zone_org_2_checker
    end
    it_should_behave_like "unnormal reject or pass worker report"
  end
  describe "checker 登陆未完成的report不能通过" do
    before do
      sign_in a_zone_org_1_checker
      visit report_detail_report_path(a_zone_org_1_report_1)
      click_button '审核通过'
    end
    it_should_behave_like "unnormal unfinished worker report can't pass"
  end
  describe "site_admin 登陆未完成的report不能通过" do
    before do
      sign_in the_site_admin
      visit report_detail_report_path(a_zone_org_1_report_1)
      click_button '审核通过'
    end
    it_should_behave_like "unnormal unfinished worker report can't pass"
  end
end
def unnormal_worker_report_index_html
    describe "非org所在zone的zoneadmin 无法访问zonesupervisor index" do
      before do
        sign_in b_zone_admin
        get zone_supervisor_organization_reports_path(a_zone_org_1)
      end
      specify do
        response.should redirect_to root_path
      end
    end
    describe "非org的checker 无法访问zonesupervisor index" do
      before do
        sign_in a_zone_org_2_checker
        get zone_supervisor_organization_reports_path(a_zone_org_1)
      end
      specify do
        response.should redirect_to root_path
      end
    end
    describe "worker 无法访问zonesupervisor index" do
      before do
        sign_in a_zone_org_1_worker
        get zone_supervisor_organization_reports_path(a_zone_org_1)
      end
      specify do
        response.should redirect_to root_path
      end
    end
    describe "supervisor 无法访问zonesupervisor index" do
      before do
        sign_in a_zone_supervisor
        get zone_supervisor_organization_reports_path(a_zone_org_1)
      end
      specify do
        response.should redirect_to root_path
      end
    end

end
def unnormal_worker_report_index_html
    describe "非org所在zone的zoneadmin 无法访问worker report index" do
      before do
        sign_in b_zone_admin
        get worker_organization_reports_path(a_zone_org_1)
      end
      specify do
        response.should redirect_to root_path
      end
    end
    describe "非org的checker 无法访问worker report index" do
      before do
        sign_in a_zone_org_2_checker
        get worker_organization_reports_path(a_zone_org_1)
      end
      specify do
        response.should redirect_to root_path
      end
    end
    describe "worker 无法访问worker report index" do
      before do
        sign_in a_zone_org_1_worker
        get worker_organization_reports_path(a_zone_org_1)
      end
      specify do
        response.should redirect_to root_path
      end
    end
    describe "supervisor 无法访问worker report index" do
      before do
        sign_in a_zone_supervisor
        get worker_organization_reports_path(a_zone_org_1)
      end
      specify do
        response.should redirect_to root_path
      end
    end
end


describe "Reports" do
  let!(:test_equipment) {FactoryGirl.create(:equipment)}

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
  let!(:a_template)           {FactoryGirl.create(:template_with_all_required,zone_admin:a_zone_admin,for_worker:true,for_supervisor:true)}
  let!(:a_unnormal_template)      {FactoryGirl.create(:template_with_3_normal_category_1_zero_check_point_category,
                                      zone_admin:a_zone_admin,for_worker:true,for_supervisor:true)}

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
  let!(:a_zone_org_1_report_3)      {FactoryGirl.create(:report_with_all_records,
                                                         organization:a_zone_org_1,
                                                         template:a_template,
                                                         committer:a_zone_org_1.worker,
                                                         status:"finished")}
  let!(:a_zone_org_1_worker_report_with_unormal_template_status_is_new) {
                                                                          FactoryGirl.create(:report_with_all_records,
                                                                                              organization:a_zone_org_1,
                                                                                              template:a_unnormal_template,
                                                                                              committer:a_zone_org_1.worker,
                                                                                              status:"new")
                                                                        }
  let!(:a_zone_org_1_worker_report_with_unormal_template_status_is_finished) {
                                                                          FactoryGirl.create(:report_with_all_records,
                                                                                              organization:a_zone_org_1,
                                                                                              template:a_unnormal_template,
                                                                                              committer:a_zone_org_1.worker,
                                                                                              status:"finished")
                                                                        }

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
  let!(:a_zone_org_1_supervisor_report_with_unormal_template_status_is_new) {
                                     FactoryGirl.create(:report_with_all_records,
                                      organization:a_zone_org_1,
                                      template:a_unnormal_template,
                                      committer:a_zone_supervisor,
                                      status:"new")
                                   }
 let!(:a_zone_org_1_supervisor_report_with_unormal_template_status_is_finished) {
                                     FactoryGirl.create(:report_with_all_records,
                                      organization:a_zone_org_1,
                                      template:a_unnormal_template,
                                      committer:a_zone_supervisor,
                                      status:"finished")
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

    normal_supervisor_report_index_html
    normal_supervisor_report_detail
    normal_supervisor_report_pass_and_reject
    normal_supervisor_report_destroy_html
    unnormal_supervisor_report_destroy_html
    unnormal_supervisor_report_pass_and_reject
    unnormal_supervisor_report_detail
    unnormal_supervisor_report_index_html
    

    normal_worker_report_index_html
    normal_worker_report_detail
    normal_worker_report_pass_and_reject
    normal_worker_report_destroy_html
    unnormal_worker_report_destroy_html
    unnormal_worker_report_pass_and_reject
    unnormal_worker_report_detail
    unnormal_worker_report_index_html

  end
end
