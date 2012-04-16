#encoding:utf-8
require 'spec_helper'

describe ZoneSupervisorRelation do
  let(:the_site_admin)      { FactoryGirl.create(:site_admin) }
  let(:a_zone_admin)        { the_site_admin.zone_admins.create(name:"testme",password:"foobar",password_confirmation:"foobar") }
  let(:a_zone)              { a_zone_admin.zones.create(name:"123",des:"3333") }
  let(:a_zone_supervisor)   { a_zone_admin.zone_supervisors.create(name:"222",password:"foobar",password_confirmation:"foobar") }
  before                    { @zone_supervisor_relation = a_zone.zone_supervisor_relations.build(zone_supervisor_id:a_zone_supervisor.id) }
  subject                   { @zone_supervisor_relation }
 
  it {should be_valid }
  it {should respond_to(:zone) }
  it {should respond_to(:zone_supervisor) }
  it {should respond_to(:zone_id) }
  it {should respond_to(:zone_supervisor_id) }
  describe "zone id缺失" do
    before { @zone_supervisor_relation.zone_id = nil }
    it {should_not be_valid }
  end
  describe "supervisor id缺失" do
    before {@zone_supervisor_relation.zone_supervisor_id = nil }
    it {should_not be_valid }
  end
end
