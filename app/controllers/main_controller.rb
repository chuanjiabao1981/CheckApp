#encoding:utf-8
class MainController < ApplicationController
  before_filter 
  before_filter :validate_equipment,  only:[:zone_supervisor_home,:worker_home]
  before_filter :checkapp_client_need_update
  def home
  	if signed_in? and current_user.session.worker?
  		#return redirect_to worker_organization_reports_path(current_user.organization,format: :mobile)
      respond_to do |format|
        format.mobile {return redirect_to worker_home_path(format: :mobile)}
        format.html   {return redirect_to worker_home_path}
      end
  	end
  	if signed_in? and current_user.session.zone_supervisor?
      respond_to do |format|
  		  format.mobile {return redirect_to zone_supervisor_home_path(format: :mobile)}
        format.html   {return redirect_to zone_supervisor_home_path}
      end
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
    # render layout:'application_one_column'
    #if request.format == 'mobile' and current_equipment_left_time <=0
    #  flash.now[:error] = "设备费用已用完，请续费，谢谢！"
    #end

    respond_to do |format|
      format.mobile {render layout:'application'}
      format.html { render layout:'application_one_column'}
    end
  end

  def zone_supervisor_home
  	return redirect_to root_path(format: request.format) unless current_user.session.zone_supervisor?
    @zone_supervisor = current_user
 	  @zones = current_user.zones
    respond_to do |format|
      format.mobile 
      format.html  
    end
  end

  def worker_home
    @organizations = current_user.organizations.paginate(page:params[:page],per_page:Rails.application.config.organization_report_page_num)
    respond_to do |format|
      format.mobile
      format.html
    end
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
