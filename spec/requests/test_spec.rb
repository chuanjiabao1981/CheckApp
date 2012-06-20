#encoding:utf-8
require 'spec_helper'
describe "test" do
  #let!(:the_site_admin)   { FactoryGirl.create(:site_admin_with_two_zone_admin)}
  #let!(:a_zone_admin)     { the_site_admin.zone_admins.first}
  #let!(:b_zone_admin)     { the_site_admin.zone_admins.last}
  #let(:a_report_record)    { FactoryGirl.create(:report_record)}
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
  #let!(:a_zone_org_1_report_1)      {FactoryGirl.create(:report_with_some_records,
  #                                            organization:a_zone_org_1,
  #                                            template:a_template,
  #                                            committer:a_zone_org_1.worker,
  #                                            status:"new")}
  it "ceshi " do
  	puts a_zone_admin.template_max_photo_num
  	puts a_template.check_categories.size
  end
end
