#encoding:utf-8
require 'spec_helper'

describe "MainPages" do
  subject {page}
  describe "not login" do
    before do
      visit root_path
    end
    it { should have_link('SiteAdmin登陆',href:site_admin_signin_path) }
  end
end
