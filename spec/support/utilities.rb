#encoding:utf-8
def sign_in(user)
  visit signin_path
  fill_in "账号",    with: user.name
  fill_in "密码", with: user.password
  click_button "登陆"
  # Sign in when not using Capybara as well.
  cookies[:remember_token] = user.remember_token
end
