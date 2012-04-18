#encoding:utf-8
require 'spec_helper'
require_relative 'user_common_spec'

describe ZoneSupervisor do
  let(:the_site_admin) { FactoryGirl.create(:site_admin) }
  let(:a_zone_admin)   { the_site_admin.zone_admins.create(name:"testme",password:"foobar",password_confirmation:"foobar") }
  before  {@user =  a_zone_admin.zone_supervisors.build(name:"test_a_zone_supervisor",password:"foobar",password_confirmation:"foobar")}
  subject {@user }

  it { should be_valid }
  it { should respond_to(:name) }
  it { should respond_to(:des)                        }
  it { should respond_to(:password)                   }
  it { should respond_to(:password_digest)            }
  it { should respond_to(:password_confirmation)      }
  it { should respond_to(:authenticate)               }
  it { should respond_to(:session)                    }
  it { should respond_to(:zone_admin_id)              }
  it { should respond_to(:zone_admin)                 }
  it { should respond_to(:zone_supervisor_relations)  }
  it { should respond_to(:zones)                      }
  it { should respond_to(:reports)                    }

  user_normal_test

  describe "删除zone_admin则解除 和zone之间的关系" do
    before do
      a_zone = a_zone_admin.zones.create(name:"eeee",des:"3333")
      a_zone.zone_supervisor_relations.create(zone_supervisor_id:@user.id)
    end
    specify do
      @user.destroy
      ZoneSupervisorRelation.find_by_zone_supervisor_id(@user.id).should be_nil
    end
  end

end
