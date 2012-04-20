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

  def zone_admin_new
  end

  def zone_admin_create
    zone_admin = ZoneAdmin.find_by_name(params[:session][:name])
    if zone_admin && zone_admin.authenticate(params[:session][:password])
      sign_in(zone_admin)
      redirect_to root_path
    else
      flash.now[:error] = '账号或密码错误'
      render 'zone_admin_new'
    end
  end

  def checker_new
  end
  def checker_create
    checker = Checker.find_by_name(params[:session][:name])
    if checker && checker.authenticate(params[:session][:password])
      sign_in(checker)
      redirect_to root_path
    else
      flash.now[:error] = '账号或密码错误'
      render 'checker_new'
    end
  end


  def destroy
    sign_out
    redirect_to root_path
  end
end
