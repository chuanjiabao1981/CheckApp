class ZoneAdminsController < ApplicationController
  before_filter :site_admin_user, only: [:new, :create]
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

private 
  def site_admin_user
    redirect_to root_path unless (signed_in? and current_user.site_admin?)
  end
end
