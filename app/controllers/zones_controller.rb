class ZonesController < ApplicationController
  before_filter :site_or_zone_admin_user,       only: [:new, :create,:edit,:update,:show,:index,:destroy]
  before_filter :correct_user_for_member,       only: [:edit,:update,:show,:destroy]
  before_filter :correct_user_for_collection,   only: [:new, :create,:index]

  def index
    @zones      = Zone.find_all_by_zone_admin_id(params[:zone_admin_id])
  end
  def show
  end
  def new
    @zone       = @zone_admin.zones.build()
  end
  def create
    @zone       = @zone_admin.zones.build(params[:zone])
    if @zone.save
      return redirect_to zone_admin_zones_path(@zone_admin)
    else
      render 'new'
    end
  end
  def edit
  end
  def update
    params[:zone][:zone_supervisor_ids] ||= []
    @zone.update_attributes(params[:zone])
    if @zone.save
      redirect_to zone_admin_zones_path(@zone_admin)
    else
      render 'edit'
    end
  end
  def destroy
    @zone.destroy
    redirect_to zone_admin_zones_path(@zone_admin)
  end
  
private 
  def correct_user_for_member
    @zone = Zone.find_by_id(params[:id])
    return redirect_to root_path if @zone.nil?
    @zone_admin = @zone.zone_admin
    return redirect_to root_path unless @zone_admin == current_user or current_user.session.site_admin?
  end
  def correct_user_for_collection
    @zone_admin = ZoneAdmin.find_by_id(params[:zone_admin_id])
    return redirect_to root_path unless @zone_admin == current_user or current_user.session.site_admin?
  end
end
