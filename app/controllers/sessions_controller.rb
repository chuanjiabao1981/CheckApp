#encoding:utf-8
class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by_name(params[:session][:name])
    if user && user.authenticate(params[:session][:password])
      if user.site_admin?  or user.zone_admin? or user.supervisor? or user.checker?
        sign_in user
        redirect_to root_path
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
