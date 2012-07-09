#encoding:utf-8
def sign_in(user)
  if user.class == SiteAdmin
    visit site_admin_signin_path
  elsif user.class == ZoneAdmin
    visit zone_admin_signin_path
  elsif user.class == Checker
    visit checker_signin_path
  elsif user.class == Worker
    visit worker_signin_path(format: :mobile)
  elsif user.class == ZoneSupervisor
    visit zone_supervisor_signin_path(foramt: :mobile)
  end
  fill_in "账号",    with: user.name
  fill_in "密码", with: user.password
  # page.driver.request.env[:HTTP_USER_AGENT] = "test"
  # print request.env
  Capybara.current_session.driver.browser.header "User_agent" ,"test-agent" 
  click_button "登陆"

  # Sign in when not using Capybara as well.
  cookies[:remember_token] = user.session.remember_token

end

def api_post_request(uri,body)
  @headers ||= {} 
  @headers['ACCEPT'] =  'application/json'
  @headers['CONTENT_TYPE'] = 'application/json'
  post uri,body,@headers
end

def api_get_request(uri)
  @headers ||= {} 
  @headers['ACCEPT'] =  'application/json'
  get uri,nil,@headers
end

def check_site_admin_left
  it {should have_link('zone管理员',href:zone_admins_path)}
  it {should have_link('设置')      }
  it {should have_link('退出',href:signout_path)}
  it {should_not have_link('SiteAdmin登陆',href:site_admin_signin_path)}
end

def check_zone_admin_left
  it { should have_link('分区管理')}
  it { should have_link('督察员')}
  it {should have_link('退出',href:signout_path)}
  it {should_not have_link('ZoneAdmin登陆',href:zone_admin_signin_path)}
  it {should have_link('设置')      }

end


