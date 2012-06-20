#encoding:utf-8
require 'spec_helper'


describe "ReportRecords" do
  subject{page}
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
  let!(:a_zone_org_1_report_2_a_record) {
                                            a_zone_org_1_report_2.report_records.first
                                        }
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
  let(:a_zone_org_1_report_5_a_record) {
                                        a_zone_org_1_report_5.report_records.first
  }
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
        #page.has_css?('td',text:'图像').should == true
        image_url          = test_record.get_photo_path
        image_css_selector = "img[src=\"#{image_url}\"]"
        page.has_css?(image_css_selector).should == true
      elsif test_record.check_point.can_video
        page.has_css?('td',text:'视频').should == true
        video_url           = test_record.get_video_path
        video_css_selector  = "a[href=\"#{video_url}\"]"
        page.has_css?(video_css_selector).should == true
      end
    end
  end
  shared_examples_for "report_record new" do
    before do
      test_check_point.can_photo = true
      test_check_point.save
      sign_in user
      visit         new_report_record_path(test_report,test_check_point)
      select        test_date_year                           ,from:'report_record_date_value_1i'
      select        test_date_month                          ,from:'report_record_date_value_2i'
      select        test_date_day                            ,from:'report_record_date_value_3i'
      choose        test_boolean_value
      fill_in       test_template.check_value.int_name        ,with:test_int_value
      fill_in       test_template.check_value.float_name      ,with:test_float_value
      fill_in       test_template.check_value.text_name       ,with:test_text_value
      attach_file   'report_record_photo_path'                  ,test_photo_path
    end
    specify do
      test_report.check_point_is_done?(test_check_point.id).should == false
      expect {click_button '新增'}.to change(ReportRecord,:count).by(1)
    end
    specify do
      click_button '新增'
      #puts test_report.report_records.last.id
      test_report.report_records.last.text_value.should           == test_text_value
      test_report.report_records.last.int_value.should            == test_int_value
      test_report.report_records.last.float_value.should          == test_float_value
      test_report.report_records.last.get_date_value.should       == "#{test_date_year}-#{test_date_month}-#{test_date_day}"
      if test_boolean_value == "report_record_boolean_value_1"
        test_report.report_records.last.get_boolean_value         == '是'
        #puts test_report.report_records.last.get_boolean_value
      else
        test_report.report_records.last.get_boolean_value         == '否'
        #puts test_report.report_records.last.get_boolean_value
      end
      test_report.report_records.last.photo_path.current_path.should_not be_nil
      File.exist?(test_report.report_records.last.photo_path.current_path).should == true
    end   
  end
  shared_examples_for "update a report" do
    before do
      test_check_point.can_photo          = true
      test_check_point.save
      test_report_record.photo_path       = File.open(test_old_pic)
      test_report_record.date_value       = '2011-12-03'
      test_report_record.save
      sign_in user
      visit edit_report_record_path(test_report_record,format: :mobile)
      # print page.html
      select        test_date_year                           ,from:'report_record_date_value_1i'
      select        test_date_month                          ,from:'report_record_date_value_2i'
      select        test_date_day                            ,from:'report_record_date_value_3i'
      choose        test_boolean_value
      fill_in       test_template.check_value.int_name        ,with:test_int_value
      fill_in       test_template.check_value.float_name      ,with:test_float_value
      fill_in       test_template.check_value.text_name       ,with:test_text_value
      attach_file   'report_record_photo_path'                  ,test_photo_path     
    end
    specify do
      test_report.should be_status_is_new
      test_report.check_point_is_done?(test_check_point.id)
      File.exist?(test_report_record.photo_path.current_path).should == true
      click_button '保存'
      test_report_record.reload
      #puts test_report.report_records.last.id
      test_report_record.text_value.should           == test_text_value
      test_report_record.int_value.should            == test_int_value
      test_report_record.float_value.should          == test_float_value
      test_report_record.get_date_value.should       == "#{test_date_year}-#{test_date_month}-#{test_date_day}"
      if test_boolean_value == "report_record_boolean_value_1"
        test_report_record.get_boolean_value         == '是'
        #puts test_report.report_records.last.get_boolean_value
      else
        test_report_record.get_boolean_value         == '否'
        #puts test_report.report_records.last.get_boolean_value
      end
      test_report_record.photo_path.current_path.should_not be_nil
      File.exist?(test_report_record.photo_path.current_path).should == true
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
  describe "new a worker report record" do
    it_should_behave_like "report_record new" do
      let(:user)                      {a_zone_org_1_worker}
      let(:test_report)               {a_zone_org_1_report_1}
      let(:test_template)             {a_template}
      let(:test_check_point)          {a_template.check_categories[1].check_points.first}
      let(:test_text_value)           {"测试+了了+加油"}
      let(:test_int_value)            {512}
      let(:test_float_value)          {5.12}
      let(:test_date_year)            {"2013"}
      let(:test_date_month)           {"11"}
      let(:test_date_day)             {"25"}
      let(:test_boolean_value)        {"report_record_boolean_value_0"}
      let(:test_photo_path)           {File.join(Rails.root, 'spec', 'support', 'report_record', 'photo', 'test.jpg')}
    end
  end
  describe "new a zone_supervisor report record" do
    it_should_behave_like "report_record new" do
      let(:user)                      {a_zone_supervisor}
      let(:test_report)               {a_zone_org_1_report_6}
      let(:test_template)             {a_template}
      let(:test_check_point)          {test_template.check_categories[1].check_points.first}
      let(:test_text_value)           {"测试+了了+加油"}
      let(:test_int_value)            {512}
      let(:test_float_value)          {5.12}
      let(:test_date_year)            {"2013"}
      let(:test_date_month)           {"11"}
      let(:test_date_day)             {"25"}
      let(:test_boolean_value)        {"report_record_boolean_value_0"}
      let(:test_photo_path)           {File.join(Rails.root, 'spec', 'support', 'report_record', 'photo', 'test.jpg')}
    end
  end
  describe "update a worker report" do
    it_should_behave_like "update a report" do
      let(:user)                    {a_zone_org_1_worker}
      let(:test_report)             {a_zone_org_1_report_1}
      let(:test_template)           {a_template}
      let(:test_report_record)      {a_zone_org_1_report_1.report_records.first}
      let(:test_check_point)        {test_report_record.check_point}
      let(:test_old_pic)            {File.join(Rails.root, 'spec', 'support', 'report_record', 'photo', 'test.jpg')}
      let(:test_new_pic)            {File.join(Rails.root, 'spec', 'support', 'report_record', 'photo', '9m.jpg')}
      let(:test_text_value)           {"测试+了了+加油"}
      let(:test_int_value)            {512}
      let(:test_float_value)          {5.12}
      let(:test_date_year)            {"2013"}
      let(:test_date_month)           {"11"}
      let(:test_date_day)             {"25"}
      let(:test_boolean_value)        {"report_record_boolean_value_0"}
      let(:test_photo_path)           {File.join(Rails.root, 'spec', 'support', 'report_record', 'photo', 'test.jpg')}
    end
  end
  describe "update a supervisor report" do
    it_should_behave_like "update a report" do
      let(:user)                    {a_zone_supervisor}
      let(:test_report)             {a_zone_org_1_report_6}
      let(:test_template)           {a_template}
      let(:test_report_record)      {a_zone_org_1_report_6.report_records.first}
      let(:test_check_point)        {test_report_record.check_point}
      let(:test_old_pic)            {File.join(Rails.root, 'spec', 'support', 'report_record', 'photo', 'test.jpg')}
      let(:test_new_pic)            {File.join(Rails.root, 'spec', 'support', 'report_record', 'photo', '9m.jpg')}
      let(:test_text_value)           {"测试+了了+加油"}
      let(:test_int_value)            {512}
      let(:test_float_value)          {5.12}
      let(:test_date_year)            {"2013"}
      let(:test_date_month)           {"11"}
      let(:test_date_day)             {"25"}
      let(:test_boolean_value)        {"report_record_boolean_value_0"}
      let(:test_photo_path)           {File.join(Rails.root, 'spec', 'support', 'report_record', 'photo', 'test.jpg')}
    end
  end
  shared_examples_for "wrong user visit report_record view" do
    describe "signin" do
      before do 
        sign_in wrong_user
        get report_record_path(test_record,format: :mobile)
      end
      specify do
        response.should redirect_to root_path(format: :mobile)
      end
    end
    describe "not signin" do
      before  {get report_record_path(test_record,format: :mobile)}
      specify {response.should redirect_to root_path}
    end
    describe "not exsit record" do
      before do
        sign_in wrong_user
        get report_record_path(1203,format: :mobile)
      end
      specify do
        response.should redirect_to root_path(format: :mobile)
      end
    end
  end
  describe "invalid user visit worker report" do
    it_should_behave_like "wrong user visit report_record view" do
      let(:wrong_user)          {a_zone_org_2_checker}
      let(:test_record)         {a_zone_org_1_report_1_a_record}
    end
    it_should_behave_like "wrong user visit report_record view" do
      before do
        a_zone_org_1.zone.zone_supervisors<<a_zone_supervisor
      end
      let(:wrong_user)          {a_zone_supervisor}
      let(:test_record)         {a_zone_org_1_report_1_a_record}
    end
    it_should_behave_like "wrong user visit report_record view" do
      let(:wrong_user)          {a_zone_admin}
      let(:test_record)         {a_zone_org_1_report_1_a_record}
    end
    it_should_behave_like "wrong user visit report_record view" do
      let(:wrong_user)          {b_zone_admin}
      let(:test_record)         {a_zone_org_1_report_1_a_record}
    end
  end
  describe "invalid user visit supervisor report" do
    it_should_behave_like "wrong user visit report_record view" do
      let(:wrong_user)          {b_zone_supervisor}
      let(:test_record)         {a_zone_org_1_report_6_a_record}
    end
    it_should_behave_like "wrong user visit report_record view" do
      let(:wrong_user)          {a_zone_org_1_worker}
      let(:test_record)         {a_zone_org_1_report_6_a_record}
    end
    it_should_behave_like "wrong user visit report_record view" do
      let(:wrong_user)          {b_zone_admin}
      let(:test_record)         {a_zone_org_1_report_6_a_record}
    end
  end
  shared_examples_for "invalid user new report record" do

    specify do
      test_report.should be_status_is_new
      test_report.check_point_is_done?(test_check_point.id).should == false
    end
    describe "get request" do
      before do
        sign_in wrong_user
        get new_report_record_path(test_report,test_check_point)
      end
      specify do
        response.should redirect_to root_path(format: :mobile)
      end
    end
    describe "post request" do
      before do
        sign_in wrong_user
        post create_report_record_path(test_report,test_check_point)
      end
      specify do
        response.should redirect_to root_path(format: :mobile)
      end
    end
  end
  shared_examples_for "valid user new record for report status is finished" do
    specify do
      test_report.should be_status_is_finished
      test_report.check_point_is_done?(test_check_point).should == false
    end
    describe "get request" do
      before do
        sign_in user
        get new_report_record_path(test_report,test_check_point)
      end
      specify do
        response.should redirect_to root_path(format: :mobile)
      end
    end
    describe "post request" do
      before do
        sign_in user
        post create_report_record_path(test_report,test_check_point)
      end
      specify do
        response.should redirect_to root_path(format: :mobile)
      end
    end
  end
  shared_examples_for "valid user new a finished checkpoint" do
    before do
      test_report.set_status_new
      test_report.save
    end
    describe "get request" do
      specify do
        test_report.should be_status_is_new
        test_report.check_point_is_done?(test_check_point.id).should == true
      end
      before do
        sign_in user
        get new_report_record_path(test_report,test_check_point)
      end
      specify do
        response.should redirect_to root_path(format: :mobile)
      end
    end
    describe "post request" do
      before do
        sign_in user
        post create_report_record_path(test_report,test_check_point)
      end
      specify do
        response.should redirect_to root_path(format: :mobile)
      end
    end
  end

  describe "invalid new worker report" do
    it_should_behave_like "valid user new record for report status is finished" do
      let(:user)                    {a_zone_org_1_worker}
      let(:test_template)           {a_template}
      let(:test_check_point)        {test_template.check_categories[1].check_points.first}
      let(:test_report)             {a_zone_org_1_report_2}
    end
    it_should_behave_like "valid user new a finished checkpoint" do
      let(:user)                {a_zone_org_1_worker}
      let(:test_report)         {a_zone_org_1_report_2}
      let(:test_template)       {a_template}
      let(:test_check_point)    {a_template.check_categories.first.check_points.first}
    end
    it_should_behave_like "invalid user new report record" do
      let(:wrong_user)            {a_zone_org_2_worker}
      let(:test_report)           {a_zone_org_1_report_1}
      let(:test_check_point)      {a_template.check_categories[1].check_points.first}
    end
    it_should_behave_like "invalid user new report record" do   
      let(:wrong_user)            {a_zone_supervisor}
      let(:test_report)           {a_zone_org_1_report_1}
      let(:test_check_point)      {a_template.check_categories[1].check_points.first}
    end

    it_should_behave_like "invalid user new report record" do   
      let(:wrong_user)            {a_zone_admin}
      let(:test_report)           {a_zone_org_1_report_1}
      let(:test_check_point)      {a_template.check_categories[1].check_points.first}
    end
  end
  describe "invalid new supervisor report" do
    it_should_behave_like "valid user new record for report status is finished" do
      let(:user)                    {a_zone_supervisor}
      let(:test_template)           {a_template}
      let(:test_check_point)        {test_template.check_categories[1].check_points.first}
      let(:test_report)             {a_zone_org_1_report_4}
    end
    it_should_behave_like "valid user new a finished checkpoint" do
      let(:user)                {a_zone_supervisor}
      let(:test_report)         {a_zone_org_1_report_5}
      let(:test_template)       {a_template}
      let(:test_check_point)    {a_template.check_categories.first.check_points.first}
    end
    it_should_behave_like "invalid user new report record" do   
      let(:wrong_user)            {b_zone_supervisor}
      let(:test_report)           {a_zone_org_1_report_6}
      let(:test_check_point)      {a_template.check_categories[1].check_points.first}
    end
    it_should_behave_like "invalid user new report record" do   
      let(:wrong_user)            {a_zone_org_1_worker}
      let(:test_report)           {a_zone_org_1_report_6}
      let(:test_check_point)      {a_template.check_categories[1].check_points.first}
    end
  end
  shared_examples_for "invalid user update report record" do

    specify do
      test_report_record.report.should be_status_is_new
    end
    describe "get request" do
      before do
        sign_in wrong_user
        get edit_report_record_path(test_report_record)
      end
      specify do
        response.should redirect_to root_path(format: :mobile)
      end
    end
    describe "put request" do
      before do
        sign_in wrong_user
        put report_record_path(test_report_record)
      end
      specify do
        response.should redirect_to root_path(format: :mobile)
      end
    end
    describe "no exist report get" do
      before do
        sign_in wrong_user
        get edit_report_record_path(1203)
      end
      specify do
        response.should redirect_to root_path(format: :mobile)
      end
    end
    describe "no exist report put" do
      before do
        sign_in wrong_user
        put report_record_path(1203)
      end
      specify do
        response.should redirect_to root_path(format: :mobile)
      end
    end
  end
  shared_examples_for "valid user update the record of a finished report" do
    specify do
      test_report_record.report.should be_status_is_finished
      test_report_record.report.committer.should == user
    end
    describe "get request" do
      before do
        sign_in user
        get edit_report_record_path(test_report_record,format: :mobile)
      end
      specify {response.should redirect_to root_path(format: :mobile)}
    end
    describe "put request" do
      before do
        sign_in user
        put report_record_path(test_report_record,format: :mobile)
      end
      specify do
        response.should redirect_to root_path(format: :mobile)
      end
    end
    describe "not exist report get" do
      before do
        sign_in user
        get edit_report_record_path(1000,format: :mobile)
      end
      specify {response.should redirect_to root_path(format: :mobile)}
    end
    describe "not exist report put" do
      before do
        sign_in user
        put report_record_path(1000,format: :mobile)
      end
      specify do
        response.should redirect_to root_path(format: :mobile)
      end     
    end
  end
  describe "invalid update worker report" do
    it_should_behave_like "valid user update the record of a finished report" do
      let(:user)                {a_zone_org_1_worker}
      let(:test_report_record)  {a_zone_org_1_report_2_a_record}
    end
    it_should_behave_like "invalid user update report record" do
      let(:wrong_user) {a_zone_org_2_worker}
      let(:test_report_record){a_zone_org_1_report_1_a_record}
    end
    it_should_behave_like "invalid user update report record" do
      let(:wrong_user) {a_zone_supervisor}
      let(:test_report_record) {a_zone_org_1_report_1_a_record}
    end
    it_should_behave_like "invalid user update report record" do
      let(:wrong_user) {a_zone_admin}
      let(:test_report_record) {a_zone_org_1_report_1_a_record}
    end
  end
  describe "invalid update supervisor report" do
    it_should_behave_like "valid user update the record of a finished report" do
      let(:user)                {a_zone_supervisor}
      let(:test_report_record)  {a_zone_org_1_report_5_a_record}
    end
    it_should_behave_like "invalid user update report record" do
      let(:wrong_user) {b_zone_supervisor}
      let(:test_report_record) {a_zone_org_1_report_6_a_record}
    end
    it_should_behave_like "invalid user update report record" do
      let(:wrong_user) {a_zone_org_1_worker}
      let(:test_report_record) {a_zone_org_1_report_6_a_record}
    end
    it_should_behave_like "invalid user update report record" do
      let(:wrong_user) {a_zone_admin}
      let(:test_report_record) {a_zone_org_1_report_6_a_record}
    end
  end
end





























