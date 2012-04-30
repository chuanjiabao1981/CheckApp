class ReportsController < ApplicationController
  before_filter :singed_in_user
  before_filter :validate_format,                         only:[:worker_report,:check_categories,:check_points,:new,:edit]
  before_filter :validate_organization_visitor,           only:[:worker_report]
  before_filter :validate_report_visitor,                 only:[:check_categories]
  before_filter :validate_report_check_points_visitor,  only:[:check_points]
  before_filter :validate_report_creater,                 only:[:new,:create]
  before_filter :validate_report_template_when_create,    only:[:create]
  before_filter :validate_report_edit_and_update_and_destroy,         only:[:edit,:update,:destroy]
  def worker_report
    if current_user.session.checker? or current_user.session.worker?
      @worker_reports = Report.where('organization_id=? and committer_type=?',params[:organization_id],'Worker')
    elsif
      @worker_reports = Report.where('organization_id=? and committer_type=? and status = ?',params[:organization_id],'Worker','finished')
    end
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
  def new
    if current_user.session.worker?
      @template_list = Template.where(for_worker:true,zone_admin_id:@organization.zone.zone_admin_id)
    elsif current_user.session.zone_supervisor?
      @template_list = Template.where(for_supervisor:true,zone_admin_id:@organization.zone.zone_admin_id)
    end
    @report = @organization.reports.build()
  end
  def create
    @report = @organization.build_a_report(params[:report],current_user)
    if @report.save
      redirect_to check_categories_report_path(@report)
    else
      if current_user.session.worker?
        @template_list = Template.where(for_worker:true,zone_admin_id:@organization.zone.zone_admin_id)
      elsif current_user.session.zone_supervisor?
        @template_list = Template.where(for_supervisor:true,zone_admin_id:@organization.zone.zone_admin_id)
      end
      render 'new',formats: [:mobile]
    end
  end


  def edit
  end
  def update
    if @report.update_attributes(reporter_name:params[:report][:reporter_name])
      redirect_to check_categories_report_path(@report,format: :mobile)
    else
      render 'edit',formats: [:mobile]
    end
  end

  def destroy
    if @report.status_is_new?
      @report.destroy
    elsif current_user.session.site_admin? or current_user.session.checker? or current_user.zone_supervisor?
      @report.destroy
    end
    return redirect_to worker_organization_reports_path(@report.organization,format: :mobile) if @report.worker_report?
    return redirect_to zone_supervisor_organization_reports(@report.organization,format: :mobile) if @report.supervisor_report?
  end

private
  #just for reportor_name
  def validate_report_edit_and_update_and_destroy
    @report = Report.find_by_id(params[:id]) 
    return redirect_to root_path if @report.nil?
    return redirect_to root_path unless @report.committer == current_user
  end
  def validate_report_template_when_create
    return root_path if params[:report][:template_id].nil?
    @template       = Template.find_by_id(params[:report][:template_id])
    #@organization 在validate_organization_visitor中已经计算过了
    if current_user.session.zone_supervisor?
      return root_path unless @template.zone_admin == current_user.zone_admin
      return root_path unless @current_user.zone_ids.include?(@organization.id)
    else
      return root_path unless @template.zone_admin == current_user.organization.zone.zone_admin
      return root_path unless @organization == current_user.organization
    end
  end
  def validate_report_creater
    #只有worker 和 zone_supervisor才能访问这个 controller
    #否则无法设置 report 的committer
    return root_path unless current_user.session.worker? or current_user.session.zone_supervisor?
    check_current_user_can_visit_the_organization(params[:organization_id])
  end
  def validate_report_check_points_visitor
    @report = Report.find_by_id(params[:id])
    return redirect_to root_path if @report.nil?
    return redirect_to root_path unless @report.template.check_category_ids.include?(params[:check_category_id].to_i)
    check_current_user_can_visit_the_organization(@report.organization_id)
  end
  def validate_report_visitor
    @report = Report.find_by_id(params[:id]) 
    return redirect_to root_path if @report.nil?
    check_current_user_can_visit_the_organization(@report.organization.id)
  end
  def validate_organization_visitor
    check_current_user_can_visit_the_organization(params[:organization_id])
  end
  def validate_format
    if request.format == :mobile
      return redirect_to root_path unless current_user.session.worker? or current_user.session.zone_supervisor?
    else request.format == :html
      return redirect_to root_path unless current_user.session.zone_admin? or current_user.session.checker? or current_user.session.site_admin?
    end
  end
  def check_current_user_can_visit_the_organization(organization_id)
    @organization = Organization.find_by_id(organization_id)
    return redirect_to root_path if @organization.nil?
    if current_user.session.zone_admin?
      return redirect_to root_path unless @organization.zone.zone_admin == current_user
    end
    if current_user.session.worker?
      return redirect_to root_path unless @organization.worker  == current_user
    end
    if current_user.session.checker?
      return redirect_to root_path unless @organization.checker == current_user
    end
    if current_user.session.zone_supervisor?
      return redirect_to root_path unless current_user.zone_ids.include?(@organization.zone.id)
    end
  end
end
