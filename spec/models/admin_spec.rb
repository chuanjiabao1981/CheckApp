# encoding: utf-8
require 'spec_helper'

describe Admin do
  before 	{@admin =  Admin.new(name:"Admin",des:"Test some desc",contact:"老",phone:"12334",password:"foobar",password_confirmation:"foobar")}
  subject	{@admin}
  
  it { should respond_to(:name)                   }
  it { should respond_to(:des)                    }
  it { should respond_to(:contact)                }
  it { should respond_to(:phone)                  }
  it { should respond_to(:password)               }
  it { should respond_to(:password_digest)        }
  it { should respond_to(:password_confirmation)  }

  it { should respond_to(:authenticate)           }

  it { should be_valid}

  describe "when name is null" do
    before	{@admin.name=" "}
    it { should_not be_valid}
  end

  describe "when name is too long" do
    before { @admin.name = "a"*20}
    it {should_not be_valid}
  end

  describe "when name has some unexpected format" do
    it "should be not valide" do
      un_valid_name = ["1 2","s#d","a v"]
      un_valid_name.each do |u_n|
        @admin.name = u_n
        @admin.should_not be_valid
      end
    end
  end

   describe "when name has expected format" do
    it "should be valide" do
      un_valid_name = ["1abb","sdddd","av1","a_b"]
      un_valid_name.each do |u_n|
        @admin.name = u_n
        @admin.should be_valid
      end
    end
  end


  describe "des is too long" do
    before { @admin.des = "dd"*200 }
    it {should_not be_valid }
  end

  describe "admin is dup" do
    before do
      @admin_dup_name = @admin.dup 
      @admin_dup_name.save
    end
    it {should_not be_valid}
  end

  describe "contact is too long" do
    before do
      @admin.contact  = "a" * 300
    end
    it {should_not be_valid}
  end

  describe "phone is too long" do
    before do
      @admin.phone = "1" * 300
    end
    it {should_not be_valid }
  end

  describe "password or password_confirmation is not present" do
    before { @admin.password = @admin.password_confirmation = " " }
    it { should_not be_valid }
  end

  describe "password mismatch password_confirmation" do
    before { @admin.password_confirmation = "mis match" }
    it {should_not be_valid}
  end

  describe "password_confirmation that is nil" do
    before { @admin.password_confirmation = nil }
    it {should_not be_valid }
  end

  describe "return value of authenticate" do
    before { @admin.save }
    let(:found_admin) { Admin.find_by_name(@admin.name) }

    describe "with valid pass" do
      it { should == found_admin.authenticate(@admin.password) }
    end

    describe "with unvalid password" do
      let(:user_for_invalid_password) {found_admin.authenticate("invalid pass")}
      it { should_not == user_for_invalid_password }
      specify { user_for_invalid_password.should be_false}
    end
  end

end
