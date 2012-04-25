#encoding:utf-8
require 'spec_helper'

describe "Api::V1::Zones" do
  let(:the_site_admin)      { FactoryGirl.create(:site_admin_with_two_zone_admin)}
  let!(:a_zone_admin)        { the_site_admin.zone_admins.first}
  let!(:a_zone_supervisor)   { a_zone_admin.zone_supervisors.first}
  let!(:a_template)     { FactoryGirl.create(:template_with_all_required,zone_admin:a_zone_admin)}
  let!(:b_template)     { FactoryGirl.create(:template_with_all_required,zone_admin:a_zone_admin)}

  before do
    a_zone_admin.zones.first.zone_supervisors<<a_zone_supervisor
    a_zone_admin.zones.last.zone_supervisors<<a_zone_supervisor
  end
  describe "GET /api_v1_zones" do
    describe "zone_supervisor" do
      describe "token错误" do
        let(:get_fail) {{"status"=>"fail", "reason"=>  { "用户名或密码"=> ["错误。请重新登陆。"] }}               }
        before do
          api_get_request(api_v1_zone_supervisor_zones_path("xxxxxx"))
        end
        it "=get fail" do
          JSON.parse(response.body).should == get_fail
        end
      end
      describe "token正确" do
        let(:get_suc)  {  
                          { "status"=>"ok",
                            "templates"=>a_zone_admin.as_json(only:[],include:{templates:Template::JSON_OPTS})[:templates],
                            "zones"=>a_zone_supervisor.as_json(only:[],include:{zones:Zone::JSON_OPTS})[:zones]
                          }
                        }
        before do
          api_get_request(api_v1_zone_supervisor_zones_path(a_zone_supervisor.session.remember_token))
        end
        it"=get suc" do
          a_zone_supervisor.zone_admin.should == a_zone_admin
          JSON.parse(response.body).should == JSON.parse(get_suc.to_json)
        end
      end
    end
    describe "worker" do
    end
  end
end
