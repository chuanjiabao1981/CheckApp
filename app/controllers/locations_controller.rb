class LocationsController < ApplicationController
  before_filter :site_or_zone_admin_user
  before_filter :correct_user_for_collection,   only: [:new, :create,:index]
  before_filter :correct_user_for_member,       only:[:edit,:update,:destroy]

  def index
    @locations      = @zone_admin.locations
  end
  def new
  	@location       = @zone_admin.locations.build()
  end
  def create
    @location       =  @zone_admin.locations.build(params[:location])
    if @location.save
      redirect_to zone_admin_locations_path(@zone_admin)
    else
      render 'new'
    end
  end
  def edit
  end
  def update
    if @location.update_attributes(params[:location])
      return redirect_to zone_admin_locations_path(@zone_admin)
    else
      render 'edit'
    end
  end
  def destroy
    @location.destroy
    return redirect_to zone_admin_locations_path(@zone_admin)
  end

private
  def correct_user_for_member
    @location               = Location.find_by_id(params[:id])
    return redirect_to root_path if not @location
    @zone_admin             = @location.zone_admin
    return redirect_to root_path unless default_correct_user_for_collection(@zone_admin)
  end

  def correct_user_for_collection
    @zone_admin             = ZoneAdmin.find_by_id(params[:zone_admin_id])
    return redirect_to root_path unless default_correct_user_for_collection(@zone_admin)
  end
end
