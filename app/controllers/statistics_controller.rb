#encoding:utf-8
class StatisticsController < ApplicationController
  before_filter :correct_user,       only: [:search]

  def search
    ##TODO:: 不能超过一个月
    if @start_date_ts != 0 and @end_date_ts != 0
      if ((@end_date_ts - @start_date_ts)/86400) > 6
        flash.now[:error] = '您的账户仅能查询6天以内的数据。'
      else
        @reports            = find_report_in_time_range(@template,@start_date,@end_date)
        @report_statistics  = ReportStatistics.new(@template)
        @reports.each do |r|
          @report_statistics.add_a_report_status(ReportStatus.new(r))
        end
      end
      # logger.debug("supervisor report num:" + @report_statistics.get_total_supervisor_report_num.to_s)
      # logger.debug("worker report num :"    + @report_statistics.get_total_worker_report_num.to_s)
    end
  end

private
  def correct_user
  	return redirect_to root_path unless signed_in?
  	@zone_admin = ZoneAdmin.find_by_id(params[:zone_admin_id])

  	return redirect_to root_path unless @zone_admin == current_user or current_user.session.site_admin?
    @template       = nil
    @start_date     = ""
    @start_date_ts  = 0
    @end_date       = ""
    @end_date_ts    = 0
    if params.has_key?(:statistics)
      @start_date     = params[:statistics][:start_date]
      @start_date_ts  = get_time_stamp_from_ymd(@start_date)
      @end_date       = params[:statistics][:end_date]
      @end_date_ts    = get_time_stamp_from_ymd(@end_date)
      @template       = Template.find_by_id(params[:statistics][:template_id])
      return redirect_to root_path unless @template.zone_admin == @zone_admin or current_user.session.site_admin?
      # logger.debug(@start_date)
      # logger.debug(@start_date_ts)
      # logger.debug(@end_date)
      # logger.debug(@end_date_ts)
      # logger.debug(@template.name)
    end
  end
  def get_time_stamp_from_ymd(str)
    if str.nil? or str.strip.empty?
      return 0
    end
    date_splits = str.split('-')
    if date_splits.length != 3
      return 0
    end
    date_splits.each do |d|
      if d.to_i.to_s != d
        if d.start_with?("0") and "0"+d.to_i.to_s == d
          next
        else
          return 0
        end
      end
    end
    return Time.utc(date_splits[0],date_splits[1],date_splits[2]).to_i
  end

end
