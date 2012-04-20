#encoding:utf-8
def sign_in(user)
  if user.class == SiteAdmin
    visit site_admin_signin_path
  elsif user.class == ZoneAdmin
    visit zone_admin_signin_path
  else
    visit signin_path
  end
  fill_in "账号",    with: user.name
  fill_in "密码", with: user.password
  click_button "登陆"
  # Sign in when not using Capybara as well.
  cookies[:remember_token] = user.session.remember_token
end

def check_site_admin_left
  it {should have_link('zone管理员',href:zone_admins_path)}
  it {should have_link('设置')      }
  it {should have_link('退出',href:signout_path)}
  it {should_not have_link('登陆',href:signin_path)}
end

def check_zone_admin_left
  it { should have_link('zone管理')}
  it { should have_link('督察员')}
  it {should have_link('退出',href:signout_path)}
  it {should_not have_link('登陆',href:signin_path)}
  it {should have_link('设置')      }

end


