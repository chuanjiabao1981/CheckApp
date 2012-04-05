#encoding: utf-8
require 'spec_helper'

describe "AuthenticationPages" do
  subject { page }
  describe "登陆页面" do
    before { visit signin_path }
    it { should have_selector('h1',    text: '登陆') }
    it { should have_selector('title', text: '登陆') }
  end
end
