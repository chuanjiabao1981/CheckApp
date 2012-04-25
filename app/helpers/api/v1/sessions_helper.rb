#encoding:utf-8
module Api::V1::SessionsHelper

  def current_api_user=(user)
    @current_api_user = user
  end
  def current_api_user
    @current_api_user ||= api_user_from_token
  end
  def valid_api_request?
    !current_api_user.nil?
  end

  def api_request_verify
    render json:{"status"=>"fail", "reason"=>  { "用户名或密码"=> ["错误。请重新登陆。"] }} unless valid_api_request?
  end
  private
    def api_user_from_token
      remember_token          = params[:token]
      current_session         = Session.find_by_remember_token(remember_token)
      current_session.login   unless current_session.nil?
    end

end
