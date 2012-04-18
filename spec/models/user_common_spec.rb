#encoding:utf-8
def user_normal_test
  it { should respond_to(:name) }
  it { should respond_to(:des)  }
  it { should respond_to(:password)               }
  it { should respond_to(:password_digest)        }
  it { should respond_to(:password_confirmation)  }
  it { should respond_to(:authenticate)           }
  it { should respond_to(:session)      }

  describe "通用测试" do
    describe "空用户名不合法" do
      before { @user.name = " " }
      it { should_not be_valid }
    end
    describe "用户名过长" do
      before  { @user.name = "t"*100 }
      it { should_not be_valid }
    end

    describe "用户包含不合法字符" do
      it "都不合法" do
        invalid_name = ["a#","a b","%%"]
        invalid_name.each do |invalid|
          @user.name = invalid
          @user.should_not be_valid
        end
      end
    end
    describe "用户描述过长" do
      before {@user.des = "asdf"*10000 }
      it {should_not be_valid }
    end

    describe "合法用户名称" do
      it "全部合法" do
        valid_name = ["abc","a_b","a1123_dd"]
        valid_name.each do |valid|
          @user.name = valid
          @user.should be_valid
        end
      end
    end
    describe "重复用户名" do
      before do 
        @dup_user = @user.dup
        @dup_user.save
      end
      it {  should_not be_valid }
    end
    describe "密码相关测试" do
      describe "xyz 测试" do
        before do 
          puts "before save digest:"+@user.password_digest
          @user.password = ''
          @user.password_confirmation = ''
          @user.save
        end
        specify do
          old_password = "foobar"
          new_password = "A"
          puts @user.password
          puts @user.password_confirmation
          puts "can use correct password:" + String(@user.authenticate(old_password) == @user)
          puts "old digest:"+@user.password_digest
          @user.should be_valid
          @user.password = ''
          @user.password_confirmation = ''
          puts @user.save
          puts "digest afer change the password"+@user.password_digest
          puts "digest in the db:"+Worker.find_by_id(@user.id).password_digest

          puts "new is valid:"+String(@user.valid?)
          puts "after change:"+@user.password_digest
        end
      end
      describe "密码为空不合法" do
        before { @user.password = @user.password_confirmation = " " }
        it {should_not be_valid}
      end
      describe "密码不匹配不合法" do
        before {@user.password_confirmation ="mis match"}
        it {should_not be_valid}
      end
      describe "确认密码为nil不合发" do
        before {@user.password_confirmation = nil }
        it {should_not be_valid }
      end
    end
    describe "remember me token" do
      before {@user.save}
      specify do
        @user.session.remember_token.should_not be_blank
      end
    end
  end
end

