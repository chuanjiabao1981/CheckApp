class OrganizationsController < ApplicationController
  before_filter :site_or_zone_admin_user,       only: [:new, :create,:edit,:update,:show,:index,:destroy]
  before_filter :correct_user_for_member,       only: [:edit,:update,:show,:destroy]
  before_filter :correct_user_for_collection,   only: [:new, :create,:index]
  before_filter :validate_equipment,            only: [:supervisor_reports,:worker_reports]
  before_filter :checkapp_client_need_update,   only: [:supervisor_reports,:worker_reports]


  def index
    @organizations = Organization.find_all_by_zone_id(params[:zone_id])
  end
  def show
  end
  def new
    @organization = @zone.organizations.build()
    @organization.build_checker()
  end
  def create
    if not user_want_checker
      params[:organization].delete(:checker_attributes)
    end
    @organization = @zone.organizations.build(params[:organization])
    if @organization.save
      return redirect_to zone_path(@zone)
    else
      if not user_want_checker
        @organization.build_checker()
      end
      render 'new'
    end
  end
  def edit
    if @organization.checker.nil?
      @organization.build_checker()
    end
  end
  def update
    params[:organization][:worker_ids] ||= []
    if not user_want_checker
      params[:organization].delete(:checker_attributes)
    end
    if @organization.update_attributes(params[:organization])
      return redirect_to zone_path(@zone)
    else
      if not user_want_checker
        @organization.build_checker()
      end
      render 'edit'
    end
  end
  def destroy
    @organization.destroy
    return redirect_to zone_path(@zone)
  end

  def supervisor_reports
    @zone          = Zone.find_by_id(params[:zone_id])
    @organizations = Organization.where(:zone_id=>params[:zone_id]).paginate(page:params[:page],per_page:Rails.application.config.organization_report_page_num)
  end

  def worker_reports
    @zone          = Zone.find_by_id(params[:zone_id])
    @organizations = Organization.where(:zone_id=>params[:zone_id]).paginate(page:params[:page],per_page:Rails.application.config.organization_report_page_num)
  end

  def all_reports
    @zone          = Zone.find_by_id(params[:zone_id])
    @organizations = Organization.where(:zone_id=>params[:zone_id]).paginate(page:params[:page],per_page:Rails.application.config.organization_report_page_num)
  end



private 
  def user_want_checker
    return false if params[:organization][:checker_attributes].nil?
    return false if params[:organization][:checker_attributes][:name].empty? and 
    params[:organization][:checker_attributes][:password].empty? and 
    params[:organization][:checker_attributes][:password_confirmation].empty?
    return true
  end
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
