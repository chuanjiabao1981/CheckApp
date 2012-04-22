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
      before  { @user.name = "t"*129 }
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
      describe "密码不匹配不合法" do
        before {@user.password_confirmation ="mis match"}
        it {should_not be_valid}
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

