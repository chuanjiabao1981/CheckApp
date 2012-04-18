#encoding:utf-8
require 'spec_helper'

describe Session do
  let!(:the_site_admin) { FactoryGirl.build(:site_admin)}
  describe "用户保存两次，remebertoken 应当不同" do
    specify do
      the_site_admin.save
      rt1 = the_site_admin.session.remember_token
      the_site_admin.save
      rt2 = the_site_admin.session.remember_token
      rt1.should_not == rt2
    end
  end
end
