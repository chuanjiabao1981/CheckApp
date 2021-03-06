#encoding:utf-8
class ZoneAdminsController < ApplicationController
  before_filter :site_admin_user, only: [:new, :create,:edit,:update,:show,:index,:destroy]

  def new
    @zone_admin_user = ZoneAdmin.new
  end
  def create
    @zone_admin_user = ZoneAdmin.new(params[:zone_admin])
    if @zone_admin_user.save
      redirect_to root_path
    else
      render 'new'
    end
  end

  def edit
    @zone_admin_user = ZoneAdmin.find_by_id(params[:id])
    if not @zone_admin_user 
      redirect_to root_path
    end
  end

  def update
    @zone_admin_user = ZoneAdmin.find(params[:id])
    if not @zone_admin_user
      redirect_to root_path
    end
    if @zone_admin_user.update_attributes(params[:zone_admin])
      redirect_to zone_admin_path(@zone_admin_user)
    else
      render 'edit'
    end
  end
  
  def show
    @zone_admin_user = ZoneAdmin.find_by_id(params[:id])
    return redirect_to root_path unless  @zone_admin_user
  end

  def index
    @zone_admin_users = ZoneAdmin.all
  end
  
  def destroy
    k = ZoneAdmin.find(params[:id])
    if not k or k == current_user
      redirect_to root_path
    else
      k.destroy
      flash[:success] = "User destroyed."
      redirect_to zone_admins_path
    end
  end

private 
  def check_zone_admin_user(user)
    redirect_to root_path if not user or not user.zone_admin?
  end
  
end
