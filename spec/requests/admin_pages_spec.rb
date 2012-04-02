# encoding: utf-8
require 'spec_helper'

describe "AdminPages" do
  subject { page }
  describe "visit admin show" do
    let(:admin) {   FactoryGirl.create(:admin)              }
    before      {   visit admin_path(admin)                 }
    it { should have_selector('td',text:admin.name)         }
    it { should have_selector('td',text:admin.des)          }
    it { should have_selector('td',text:admin.contact)      }
    it { should have_selector('td',text:admin.phone)        }  
  end

  describe "visit not exsits admin" do
    before    {   get admin_path(123)   }
    specify   {response.should redirect_to (admins_path) }
  end
end
