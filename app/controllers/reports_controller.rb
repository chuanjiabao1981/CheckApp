class ReportsController < ApplicationController
  before_filter :singed_in_user,only:[:worker_report,:check_categories]
  before_filter :user_can_visit_worker_report,only:[:worker_report]
  before_filter :user_can_visit_report_check_categories,only:[:check_categories]
  before_filter :user_can_visit_report_check_points,only:[:check_points]
  def worker_report
    @worker_reports = Report.where('organization_id=? and committer_type=?',params[:organization_id],'Worker')
    respond_to do |format|
      format.mobile
    end
  end
  def check_categories
    respond_to do |format|
      format.mobile
    end
  end
  def check_points
    @check_category = CheckCategory.find_by_id(params[:check_category_id])
    respond_to do |format|
      format.mobile
    end
  end

private
  def user_can_visit_report_check_points
    @report = Report.find_by_id(params[:id])
    return redirect_to root_path if @report.nil?
    return redirect_to root_path unless @report.template.check_category_ids.include?(params[:check_category_id].to_i)
    validate_visit_user(@report.organization_id)
  end
  def user_can_visit_report_check_categories
    @report = Report.find_by_id(params[:id]) 
    return redirect_to root_path if @report.nil?
    validate_visit_user(@report.organization.id)
  end
  def user_can_visit_worker_report
    validate_visit_user(params[:organization_id])
  end
  def validate_visit_user(organization_id)
    @organization = Organization.find_by_id(organization_id)
    return redirect_to root_path if @organization.nil?
    if current_user.session.zone_admin?
      return redirect_to root_path unless @organization.zone.zone_admin == current_user
    end
    if current_user.session.worker?
      return redirect_to root_path unless @organization.worker  == current_user
    end
    if current_user.session.zone_supervisor?
      return redirect_to root_path if current_user.zones.find('id=?',@organization.zone.id).nil?
    end

  end
end
