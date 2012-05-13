class MainController < ApplicationController
  def home
  	if signed_in? and current_user.session.worker?
  		return redirect_to worker_organization_reports_path(current_user.organization,format: :mobile)
  	end
  	if signed_in? and current_user.session.zone_supervisor?
  		return redirect_to zone_supervisor_home_path(format: :mobile)
  	end
  end
  def zone_supervisor_home
  	return redirect_to root_path(format: :mobile) unless current_user.session.zone_supervisor?
 	  @zones = current_user.zones
  end
  def zone_admin_home
    return redirect_to root_path unless  current_user.session.zone_admin?
    @zones = current_user.zones
  end
end
