#encoding:utf-8
require 'spec_helper'

describe "Api::V1::Sessions" do
  let(:the_site_admin)    {FactoryGirl.create(:site_admin_with_two_zone_admin) }
  let(:a_zone_supervisor) {the_site_admin.zone_admins.first.zone_supervisors.first}
  let(:a_worker)          {the_site_admin.zone_admins.first.zones.first.organizations.first.worker}
  before do
    a_zone_supervisor.password = 'foobar'
    a_worker.password          = 'foobar'
  end
  describe "ZoneSupervisor" do
    let(:login_hash)      {{session:{:name=>a_zone_supervisor.name,"password"=>a_zone_supervisor.password}}}
    let(:login_suc)       {{"status"=>"ok",   "login"=>   a_zone_supervisor.session.as_json}}
    let(:login_fail)      {{"status"=>"fail", "reason"=>  { "用户名或密码"=> ["错误"] }}               }
    describe "正确密码" do
      before do
        api_post_request(api_v1_zone_supervisor_login_path,login_hash.to_json)
      end
      it "should equal" do
         JSON.parse(response.body).should == login_suc
      end
    end
    describe "密码不正确" do
      before do
        login_hash[:session][:name]="11111"
        api_post_request(api_v1_zone_supervisor_login_path,login_hash.to_json)
      end
      it "should fail" do
        JSON.parse(response.body).should == login_fail
      end
    end
  end
  describe "Worker" do
    let(:login_hash)      {{session:{:name=>a_worker.name,"password"=>a_worker.password}}}
    let(:login_suc)       {{"status"=>"ok",   "login"=>   a_worker.session.as_json}}
    let(:login_fail)      {{"status"=>"fail", "reason"=>  { "用户名或密码"=> ["错误"] }}               }
    describe "正确密码" do
      before do
        api_post_request(api_v1_worker_login_path,login_hash.to_json)
      end
      it "获取正常token" do
        JSON.parse(response.body).should == login_suc
      end
    end
    describe "错误密码" do
      before do
        login_hash[:session][:password]="xxxx"
        api_post_request(api_v1_worker_login_path,login_hash.to_json)
      end
      it "获取错误原因" do
        JSON.parse(response.body).should == login_fail
      end
    end
  end
end
