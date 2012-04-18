#encoding:utf-8
require 'spec_helper'
require_relative 'user_common_spec'


describe Checker do
  before  {@user = FactoryGirl.build(:checker)}
  subject {@user}
  it      {should be_valid}
  it      {should respond_to(:organization) }
  it      {should respond_to(:organization_id)}
  user_normal_test
end
