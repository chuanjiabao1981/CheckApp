require 'spec_helper'

describe "ZoneAdminHomes" do

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
  describe "zone_admin home page" do
  	before do
  		sign_in a_zone_admin
  		get zone_admin_home_path(a_zone_admin)
  	end
  	specify do
  		
  	end
  end
end
