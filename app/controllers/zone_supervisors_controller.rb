class ZoneSupervisorsController < ApplicationController
  before_filter :site_or_zone_admin_user,       only: [:new, :create,:edit,:update,:show,:index,:destroy]
  before_filter :correct_user_for_member,       only: [:edit,:update,:show,:destroy]
  before_filter :correct_user_for_collection,   only: [:new, :create,:index]

  def index
    @zone_supervisors       = @zone_admin.supervisors
  end
  def show
  end
  def new
    @zone_supervisor = User.new
  end
  def create
    @zone_supervisor = @zone_admin.supervisors.build(params[:user])
    @zone_supervisor.zone_supervisor = true
    if @zone_supervisor.save
      redirect_to zone_admin_zone_supervisors_path(@zone_admin)
    else
      render 'new'
    end
  end
  def edit
  end
  def update
    if @zone_supervisor.update_attributes(params[:user])
      return redirect_to zone_admin_zone_supervisors_path(@zone_admin)
    else
      render 'edit'
    end
  end
  def destroy
    @zone_supervisor.destroy
    return redirect_to zone_admin_zone_supervisors_path(@zone_admin)
  end

private 
  def correct_user_for_member
    @zone_supervisor        = User.find_by_id(params[:id])
    return redirect_to root_path if not @zone_supervisor
    @zone_admin             = @zone_supervisor.admin
    return redirect_to root_path if not @zone_admin
    return redirect_to root_path unless @zone_admin == current_user or current_user.site_admin?
  end

  def correct_user_for_collection
    @zone_admin             = User.find_by_id(params[:zone_admin_id])
    return redirect_to root_path if not @zone_admin
    return redirect_to root_path unless @zone_admin == current_user or current_user.site_admin?
  end
end
