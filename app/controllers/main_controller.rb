class MainController < ApplicationController
  def home
  	if signed_in? and current_user.session.worker?
  		return redirect_to worker_organization_reports_path(current_user.organization,format: :mobile)
  	end
  	if signed_in? and current_user.session.zone_supervisor?
  		return redirect_to zone_supervisor_home_path(format: :mobile)
  	end
    if signed_in? and current_user.session.zone_admin?
      return redirect_to zone_admin_home_path(current_user)
    end
    if signed_in? and current_user.session.checker?
      return redirect_to checker_home_path(current_user)
    end
    if signed_in? and current_user.session.site_admin?
      return redirect_to zone_admins_path
    end
    render layout:'application_one_column'
  end

  def zone_supervisor_home
  	return redirect_to root_path(format: :mobile) unless current_user.session.zone_supervisor?
 	  @zones = current_user.zones
  end

  def zone_admin_home
    if current_user.session.zone_admin?
      @zone_admin = current_user
    elsif current_user.session.site_admin?
      @zone_admin = ZoneAdmin.find_by_id(params[:zone_admin_id])
      return redirect_to root_path if @zone_admin.nil?
    else
      return redirect_to root_path
    end
    @zones = @zone_admin.zones
  end
  def checker_home
    return redirect_to root_path unless current_user.session.checker?
    @organization = current_user.organization
  end
end
