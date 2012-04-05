#encoding: utf-8
require 'spec_helper'

describe "StaticPages" do

  subject { page }
  describe "SiteAdmin的首页" do
    before { visit site_admin_path}
    it {should have_link('zone管理员')}
    it {should have_link('模板管理') }
  end

  describe "ZoneAdmin的首页" do
    before {visit zone_admin_path}
    it { should have_link('zone管理')}
    it { should have_link('督察员')}
  end

  describe "Checker的首页" do
    before {visit checker_path }
    it { should have_link('机构管理') }
  end
  
  describe "Supervisor的首页" do
    before { visit supervisor_path }
    it { should have_link('zone') }
  end
end
