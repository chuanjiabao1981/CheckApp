class OrganizationsController < ApplicationController
  before_filter :site_or_zone_admin_user,       only: [:new, :create,:edit,:update,:show,:index,:destroy]
  before_filter :correct_user_for_member,       only: [:edit,:update,:show,:destroy]
  before_filter :correct_user_for_collection,   only: [:new, :create,:index]

  def index
    @organizations = Organization.find_all_by_zone_id(params[:zone_id])
  end
  def show
  end
  def new
    @organization = @zone.organizations.build()
    @organization.build_checker()
    @organization.build_worker()
  end
  def create
    @organization = @zone.organizations.build(params[:organization])
    if @organization.save
      return redirect_to zone_organizations_path(@zone)
    else
      render 'new'
    end
  end
  def edit
  end
  def update
    if @organization.update_attributes(params[:organization])
      return redirect_to zone_organizations_path(@zone)
    else
      render 'edit'
    end
  end
  def destroy
    @organization.destroy
    return redirect_to zone_organizations_path(@zone)
  end

private 
  def correct_user_for_member
    @organization = Organization.find_by_id(params[:id])
    return redirect_to root_path if @organization.nil?
    @zone         = @organization.zone
    return redirect_to root_path if @zone.nil?
    @zone_admin   = @zone.zone_admin
    return redirect_to root_path if @zone_admin.nil?
    return redirect_to root_path unless @zone_admin == current_user or current_user.session.site_admin?
  end
  def correct_user_for_collection
    @zone = Zone.find_by_id(params[:zone_id])
    return redirect_to root_path if @zone.nil?
    @zone_admin = @zone.zone_admin
    return redirect_to root_path if @zone_admin.nil?
    return redirect_to root_path unless @zone_admin == current_user or current_user.session.site_admin?
  end
end
