#encoding:utf-8
class SessionsController < ApplicationController

  def site_admin_new
  end
  def site_admin_create
    site_admin = SiteAdmin.find_by_name(params[:session][:name])
    if site_admin && site_admin.authenticate(params[:session][:password])
      sign_in(site_admin)
      redirect_to root_path
    else
      flash.now[:error] = '账号或密码错误'
      render 'site_admin_new'
    end
  end

  def new
  end

#  def create
#    user = User.find_by_name(params[:session][:name])
#    if user && user.authenticate(params[:session][:password])
#      if user.site_admin?  or user.zone_admin? or user.zone_supervisor? or user.org_checker?
#        sign_in user
#        redirect_to root_path
#      else
#        flash.now[:error] = '账号未启用'
#        render 'new'
#      end
#    else
#      flash.now[:error] = '账号或密码错误'
#      render 'new'
#    end
#  end

  def destroy
    sign_out
    redirect_to root_path
  end
end
