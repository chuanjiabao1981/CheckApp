require 'spec_helper'

describe "Api::V1::Sessions" do
  let(:a_zone_supervisor) { FactoryGirl.create(:zone_supervisor) }
  describe "GET /api_v1_sessions" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      post api_v1_zone_supervisor_login_path, :session=>{:name=>a_zone_supervisor.name,:password=>a_zone_supervisor.password}
      puts response.body
      puts a_zone_supervisor.session.remember_token
      puts JSON.parse(response.body).class
      @expect_respons = {"status"=>"ok","token"=>a_zone_supervisor.session.remember_token}
      JSON.parse(response.body).should == @expect_respons
      response.status.should be(200)
    end
  end
end
