#encoding:utf-8
require 'spec_helper'
describe "test" do
  let!(:the_site_admin)   { FactoryGirl.create(:site_admin_with_two_zone_admin)}
  let!(:a_zone_admin)     { the_site_admin.zone_admins.first}
  let!(:b_zone_admin)     { the_site_admin.zone_admins.last}
  it "ceshi " do
    puts a_zone_admin.valid?
    a_zone_admin.errors.each do |m|
      puts m,a_zone_admin.errors[m]
    end
    #puts the_site_admin.zone_admins.first.name
    #puts the_site_admin.zone_admins.last.name
    b_zone_admin.should be_valid
  end
end
