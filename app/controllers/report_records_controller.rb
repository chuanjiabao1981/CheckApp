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
    deal_with_base64_data(params)
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
        format.json   {return render json:json_errors(@report_record.errors)}
      end
    end
  end
  def edit
    respond_to do |format|
      format.mobile
    end
  end
  def update
    deal_with_base64_data(params)
    if @report_record.update_attributes(params[:report_record]) 
      respond_to do |format|
        format.mobile {return redirect_to report_record_path(@report_record,format: :mobile)}
        format.json   {return render json:report_record_id_json(@report_record)}
      end
    else
      respond_to do |format|
        format.mobile {return render 'edit',formats: [:mobile] }
        format.json   {return render json:json_errors(@report_record.errors)}
      end
    end
  end

private
  def validate_user_new
    error = nil 
    @report         = Report.find_by_id(params[:id])

    if not current_user.session.worker? and not  current_user.session.zone_supervisor?
      error =  I18n.t('errors.session.type_wrong')
    elsif @report.nil?
      error = I18n.t('errors.report.id_not_exsits')
    elsif @report.check_point_is_done?(params[:check_point_id])
      error = I18n.t('errors.check_point.alreay_done')
    elsif @report.status_is_finished?
      error = I18n.t('errors.report.status_is_finished')
    else
      @check_point    = CheckPoint.find_by_id(params[:check_point_id])
      if @check_point.nil?
        error = I18n.t('errors.check_point.id_not_exsits')
      else 
        @check_category = @check_point.check_category
        if @check_category.nil? 
          error = I18n.t('errors.check_category.id_not_exsits')
        elsif @report.template  != @check_category.template 
          error = I18n.t('errors.template.not_match')
        elsif @report.committer != current_user
          error = I18n.t('errors.report.not_owner')
        end
      end
    end
    if not error.nil?
      Rails.logger.debug(error)
      respond_to do |format|
        format.mobile {return redirect_to root_path(format: :mobile)}
        format.json   {return render json:json_base_errors(error)}
      end
    end
    #return redirect_to root_path(format: :mobile) unless current_user.session.worker? or current_user.session.zone_supervisor?
    #@report         = Report.find_by_id(params[:id])
    #return redirect_to root_path(format: :mobile) if @report.nil?
    #logger.debug("before check_point is finished test")
    #return redirect_to root_path(format: :mobile) if @report.check_point_is_done?(params[:check_point_id])
    #logger.debug("after check_point is finished test")
    #logger.debug("before report is finished test")
    #return redirect_to root_path(format: :mobile) if @report.status_is_finished?
    #logger.debug("after report is finished test")
    #@check_point    = CheckPoint.find_by_id(params[:check_point_id])
    #return redirect_to root_path(format: :mobile) if @check_point.nil?
    #@check_category = @check_point.check_category
    #return redirect_to root_path(format: :mobile) if @check_category.nil?
    #return redirect_to root_path(format: :mobile) unless @report.template == @check_category.template
    #logger.debug("before user check")
    #return redirect_to root_path(format: :mobile) unless @report.committer == current_user
    #logger.debug("after user check")
  end
  def validate_user_visitor
    error = nil
    @report_record     = ReportRecord.find_by_id(params[:id])

    if not current_user.session.worker? and not  current_user.session.zone_supervisor?
      error =  I18n.t('errors.session.type_wrong')
    elsif @report_record.nil?
      error = I18n.t('errors.report_record.id_not_exsits')
    else
      @report            = @report_record.report
      if @report.nil?
        error = I18n.t('errors.report.id_not_exsits')
      elsif @report.committer != current_user and action_name != 'show'
        error = I18n.t('errors.report.not_owner')
      elsif @report.status_is_finished? and action != 'show'
        error = I18n.t('errors.report.status_is_finished')
      else
        @organization      = @report.organization
        @template          = @report.template
        @check_value       = @template.check_value
        if @organization.nil?
          error = I18n.t('errors.organization.id_not_exsits')
        elsif @template.nil?
          error = I18n.t('errors.template.id_not_exsits')
        elsif @check_value.nil?
          error = I18n.t('errors.check_value.id_not_exsits')
        end 
      end
    end

    if not error.nil?
      Rails.logger.debug(error)
      respond_to do |format|
        format.mobile {return redirect_to root_path(format: :mobile)}
        format.json   {return render json:json_base_errors(error)}
      end
    end
    #return redirect_to root_path(format: :mobile) unless current_user.session.worker? or current_user.session.zone_supervisor?
    #@report_record     = ReportRecord.find_by_id(params[:id])
    #return redirect_to root_path(format: :mobile) if @report_record.nil?
    #@report            = @report_record.report
    #return redirect_to root_path(format: :mobile) if @report.nil?
    #logger.debug("before report owner test")
    ##非owner只能看 不能改
    #return redirect_to root_path(format: :mobile) if @report.committer != current_user and action_name != 'show'
    #logger.debug("after report owner test")
    #logger.debug("before report status finished")
    #return redirect_to root_path(format: :mobile) if @report.status_is_finished? and action_name !='show'
    #logger.debug("after report status finished")
    #@organization      = @report.organization
    #return redirect_to root_path(format: :mobile) if @organization.nil?
    #@template          = @report.template
    #return redirect_to root_path(format: :mobile) if @template.nil?
    #@check_value       = @template.check_value
    #return redirect_to root_path(format: :mobile) if @check_value.nil?
  end
end
