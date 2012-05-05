class ReportRecordsController < ApplicationController
  before_filter :singed_in_user
  before_filter :validate_user_visitor,only:[:show]

  def show
  end

private
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
