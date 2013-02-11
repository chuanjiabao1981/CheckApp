class ReportRecordsController < ApplicationController
  include ReportRecordsHelper

  before_filter :singed_in_user
  before_filter :validate_user_visitor,only:[:show,:edit,:update]
  before_filter :validate_user_new,only:[:new_report_record,:create_report_record]

  def show
  end
  def new_report_record
    @report_record = @report.report_records.build
    @report_record.check_point_id    = params[:check_point_id]
    @report_record.check_category_id = @check_point.check_category.id
    @report_record.date_value        = nil
    if @check_point.can_photo?
      get_photo_num(@check_point).times do 
        @report_record.build_photo_media 
      end
    elsif @check_point.can_video?
      @report_record.build_video_media
    end
    respond_to do |format|
      format.mobile 
      format.json   {return render json:new_report_record_json(@report_record,@check_point)}
    end
  end
  def create_report_record
    deal_with_base64_photo_data(params)
    Rails.logger.debug(params)
    @report_record = @report.report_records.build(params[:report_record])
    @report_record.check_point_id    = params[:check_point_id]
    @report_record.check_category_id = @check_point.check_category.id
    if @report_record.save
      respond_to do |format|
        format.mobile { return redirect_to report_record_path(@report_record,format: :mobile)}
        format.json   { return render json:report_record_id_json(@report_record)}
      end
    else
      respond_to do |format|
        format.mobile {return render 'new_report_record',formats: [:mobile] }
        format.json   {return render json:{aaaa:"222"}}
      end
    end
  end
  def edit
    respond_to do |format|
      format.mobile
    end
  end
  def update
    Rails.logger.debug(params)
    deal_with_base64_photo_data(params)
    Rails.logger.debug(params)
    if @report_record.update_attributes(params[:report_record]) 
      respond_to do |format|
        format.mobile {return redirect_to report_record_path(@report_record,format: :mobile)}
        format.json   {return render json:report_record_id_json(@report_record)}
      end
    else
      respond_to do |format|
        format.mobile {return render 'edit',formats: [:mobile] }
        format.json   {return render json:{aaa:"22222"}}
      end
    end
  end

private
  def validate_user_new
    return redirect_to root_path(format: :mobile) unless current_user.session.worker? or current_user.session.zone_supervisor?
    @report         = Report.find_by_id(params[:id])
    return redirect_to root_path(format: :mobile) if @report.nil?
    logger.debug("before check_point is finished test")
    return redirect_to root_path(format: :mobile) if @report.check_point_is_done?(params[:check_point_id])
    logger.debug("after check_point is finished test")
    logger.debug("before report is finished test")
    return redirect_to root_path(format: :mobile) if @report.status_is_finished?
    logger.debug("after report is finished test")
    @check_point    = CheckPoint.find_by_id(params[:check_point_id])
    return redirect_to root_path(format: :mobile) if @check_point.nil?
    @check_category = @check_point.check_category
    return redirect_to root_path(format: :mobile) if @check_category.nil?
    return redirect_to root_path(format: :mobile) unless @report.template == @check_category.template
    logger.debug("before user check")
    return redirect_to root_path(format: :mobile) unless @report.committer == current_user
    logger.debug("after user check")
  end
  def validate_user_visitor
    return redirect_to root_path(format: :mobile) unless current_user.session.worker? or current_user.session.zone_supervisor?
    @report_record     = ReportRecord.find_by_id(params[:id])
    return redirect_to root_path(format: :mobile) if @report_record.nil?
    @report            = @report_record.report
    return redirect_to root_path(format: :mobile) if @report.nil?
    logger.debug("before report owner test")
    ##非owner只能看 不能改
    return redirect_to root_path(format: :mobile) if @report.committer != current_user and action_name != 'show'
    logger.debug("after report owner test")
    logger.debug("before report status finished")
    return redirect_to root_path(format: :mobile) if @report.status_is_finished? and action_name !='show'
    logger.debug("after report status finished")
    @organization      = @report.organization
    return redirect_to root_path(format: :mobile) if @organization.nil?
    @template          = @report.template
    return redirect_to root_path(format: :mobile) if @template.nil?
    @check_value       = @template.check_value
    return redirect_to root_path(format: :mobile) if @check_value.nil?
  end
end
