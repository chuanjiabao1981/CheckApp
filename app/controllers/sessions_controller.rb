#encoding:utf-8
class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by_name(params[:session][:name])
    if user && user.authenticate(params[:session][:password])
      if user.site_admin?
        sign_in user
        redirect_to site_admin_path
      elsif user.zone_admin?
        sign_in user
        redirect_to zone_admin_path
      elsif user.supervisor?
        sign_in user
        redirect_to supervisor_path
      elsif user.checker?
        sign_in user
        redirect_to checker_path
      else
        flash.now[:error] = '账号未启用'
        render 'new'
      end
    else
      flash.now[:error] = '账号或密码错误'
      render 'new'
    end
  end

  def destroy
    sign_out
    redirect_to root_path
  end
end
