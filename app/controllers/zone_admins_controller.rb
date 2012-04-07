#encoding:utf-8
class ZoneAdminsController < ApplicationController
  before_filter :site_admin_user, only: [:new, :create,:edit,:update]

  def new
    @user = User.new
  end
  def create
    @user = User.new(params[:user])
    @user.zone_admin = true
    if @user.save
      redirect_to root_path
    else
      render 'new'
    end
  end

  def edit
    @user = User.find_by_id(params[:id])
    if not @user or not @user.zone_admin?
      redirect_to root_path
    end
  end

  def update
    @user = User.find(params[:id])
    if not @user or not @user.zone_admin?
      redirect_to root_path
    end
    if @user.update_attributes(params[:user])
      ##todo::这里要跳转到zone_admin展示页面
      redirect_to root_path
    else
      render 'edit'
    end
  end

private 
  def site_admin_user
    redirect_to root_path unless (signed_in? and current_user.site_admin?)
  end
end
