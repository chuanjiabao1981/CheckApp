class ReportRecordsController < ApplicationController
  before_filter :singed_in_user
  before_filter :validate_user_visitor,only:[:show]
  before_filter :validate_user_new,only:[:new_report_record,:create_report_record]

  def show
  end
  def new_report_record
    @report_record = @report.report_records.build
    @report_record.check_point_id    = params[:check_point_id]
    @report_record.check_category_id = @check_point.check_category.id
  end
  def create_report_record
    @report_record = @report.report_records.build(params[:report_record])
    @report_record.check_point_id    = params[:check_point_id]
    @report_record.check_category_id = @check_point.check_category.id
    if @report_record.save
      redirect_to report_record_path(@report_record,format: :mobile)
    else
      render 'show',formats: [:mobile]
    end
  end

private
  def validate_user_new
    return redirect_to root_path unless current_user.session.worker? or current_user.session.zone_supervisor?
    @report         = Report.find_by_id(params[:id])
    return redirect_to root_path if @report.nil?
    logger.debug(@report.check_point_is_done?(params[:check_point_id]))
    return redirect_to root_path if @report.check_point_is_done?(params[:check_point_id])
    @check_point    = CheckPoint.find_by_id(params[:check_point_id])
    return redirect_to root_path if @check_point.nil?
    @check_category = @check_point.check_category
    return redirect_to root_path if @check_category.nil?
    return redirect_to root_path unless @report.template == @check_category.template
    return redirect_to root_path unless @report.committer == current_user
  end
  def validate_user_visitor
    return redirect_to root_path unless current_user.session.worker? or current_user.session.zone_supervisor?
    @report_record     = ReportRecord.find_by_id(params[:id])
    return redirect_to root_path if @report_record.nil?
    @report            = @report_record.report
    return redirect_to root_path if @report.nil?
    return redirect_to root_path unless @report.committer == current_user
    @organization      = @report.organization
    return redirect_to root_path if @organization.nil?
    @template          = @report.template
    return redirect_to root_path if @template.nil?
    @check_value       = @template.check_value
    return redirect_to root_path if @check_value.nil?
  end
end
