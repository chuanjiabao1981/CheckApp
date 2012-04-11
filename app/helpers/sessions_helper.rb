module SessionsHelper
  def sign_in(user)
    cookies.permanent[:remember_token] = user.remember_token
    current_user = user
  end
  def sign_out
    current_user = nil
    cookies.delete(:remember_token)
  end
  def current_user=(user)
    @current_user = user
  end
  def current_user
    @current_user ||= user_from_remember_token
  end
  def signed_in?
    !current_user.nil?
  end

  def site_admin_user
    redirect_to root_path unless (signed_in? and current_user.site_admin?)
  end

  def site_or_zone_admin_user
    redirect_to root_path unless (signed_in? and (current_user.site_admin? or current_user.zone_admin?))
  end

  private

    def user_from_remember_token
      remember_token = cookies[:remember_token]
      User.find_by_remember_token(remember_token) unless remember_token.nil?
    end

end
