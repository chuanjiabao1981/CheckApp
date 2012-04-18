#encoding:utf-8
require 'spec_helper'
require_relative 'user_common_spec'

describe SiteAdmin do
  before  {@user = FactoryGirl.build(:site_admin) }
  subject {@user }
  it { should be_valid }
  it { should respond_to(:name) }
  it { should respond_to(:des)  }
  it { should respond_to(:password)               }
  it { should respond_to(:password_digest)        }
  it { should respond_to(:password_confirmation)  }
  it { should respond_to(:authenticate)           }
  it { should respond_to(:zone_admins)            }

  it { should be_valid        }

  user_normal_test

end
