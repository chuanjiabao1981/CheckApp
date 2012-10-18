#encoding:utf-8
require "prawn"
class ReportsController < ApplicationController
  before_filter :singed_in_user
  before_filter :validate_format,                         only:[:worker_report,:check_categories,:check_points,:new,:edit,:supervisor_report,:report_detail,:pass,:reject]
  before_filter :validate_organization_visitor,           only:[:worker_report,:supervisor_report]
  before_filter :validate_report_visitor,                 only:[:check_categories,:report_detail,:pass,:reject,:destroy,:edit,:update]
  before_filter :validate_report_check_points_visitor,    only:[:check_points]
  before_filter :validate_report_creater,                 only:[:new,:create]
  before_filter :validate_report_template_when_create,    only:[:create]
  before_filter :validate_report_edit_and_update_and_destroy,         only:[:edit,:update,:destroy,:pass,:reject]
  before_filter :validate_equipment#,                      only:[:worker_report,:check_categories,:supervisor_report]
  before_filter :checkapp_client_need_update
  def worker_report
    #if current_user.session.zone_admin? or current_user.session.zone_supervisor?
    #  @worker_reports = @organization.get_all_finished_worker_report.paginate(page:params[:page],per_page:10)
    #elsif
    #  @worker_reports = @organization.get_all_worker_report.paginate(page:params[:page],per_page:10)
    #end
    @worker_reports   = @organization.get_all_worker_report.paginate(page:params[:page],per_page:10)
    @zone             = @organization.zone
    respond_to do |format|
      format.mobile
      format.html
    end
  end
  def supervisor_report
    #if current_user.session.checker? or current_user.session.worker?
    #  @supervisor_reports = @organization.get_all_finished_supervisor_report.paginate(page:params[:page],per_page:10)
    #elsif
    #  @supervisor_reports = @organization.get_all_supervisor_report.paginate(page:params[:page],per_page:10)
    #end
    @supervisor_reports   = @organization.get_all_supervisor_report.paginate(page:params[:page],per_page:10)
    @zone_admin = @organization.zone.zone_admin
    @zone       = @organization.zone
    respond_to do |format|
      format.mobile
      format.html
    end
  end
  def check_categories
    @zone       = @organization.zone
    respond_to do |format|
      format.mobile
    end
  end
  def check_points
    @check_category             = CheckCategory.find_by_id(params[:check_category_id])
    @template                   = @check_category.template
    @check_point_start_no       = 0
    @template.check_categories.each do |cc|
      break if cc.id.to_i == params[:check_category_id].to_i
      @check_point_start_no     = @check_point_start_no + cc.check_points.size
    end
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
    @location_list  = @organization.zone.zone_admin.locations
    @report         = @organization.reports.build()
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
      @location_list  = @organization.zone.zone_admin.locations
      render 'new',formats: [:mobile]
    end
  end


  def edit
    @location_list  = @organization.zone.zone_admin.locations
  end
  def update
    if @report.update_attributes(reporter_name:params[:report][:reporter_name],location_id:params[:report][:location_id])
      redirect_to check_categories_report_path(@report,format: :mobile)
    else
      @location_list  = @organization.zone.zone_admin.locations
      render 'edit',formats: [:mobile]
    end
  end

  def destroy
    if @report.status_is_new?
      @report.destroy
    elsif current_user.session.site_admin? or current_user.session.checker? or current_user.session.zone_admin?
      @report.destroy
    end
    respond_to do |format|
      format.html do
        return redirect_to worker_organization_reports_path(@report.organization) if @report.worker_report?
        return redirect_to zone_supervisor_organization_reports_path(@report.organization) if @report.supervisor_report?
      end
      format.mobile do
        return redirect_to worker_organization_reports_path(@report.organization,format: :mobile) if @report.worker_report?
        return redirect_to zone_supervisor_organization_reports_path(@report.organization,format: :mobile) if @report.supervisor_report?
      end
    end
    
  end

  def report_detail
    @zone_admin = @report.organization.zone.zone_admin
    @checker    = @report.organization.checker
    respond_to do |format|
      format.html
      format.pdf do 
        @report.download_num += 1
        @report.save
        send_data generate_pdf(@report),\
        filename:"#{@organization.zone.name}_(#{@report.get_report_type_text})#{@organization.name}_#{@report.template.name}_#{I18n.localize(@report.created_at, format: :normal)}.pdf",\
        type: "application/pdf"
      end
    end
  end
  def pass
    if @report.finished?
      @report.set_status_finished
      @report.save
      redirect_to report_detail_report_path(@report)
    else
      flash[:error] = '报告未完成不能审核通过!'
      render 'report_detail'
    end
  end
  def reject
    @report.set_status_new
    if @report.save
      redirect_to report_detail_report_path(@report)
    else
      logger.error("report status change error")
    end
  end

private
  #just for reportor_name
  def validate_report_edit_and_update_and_destroy
    # 权限限制不要太严，通过ui控制。这样权限部分比较简单
    #if @report.supervisor_report?
    #  return redirect_to root_path unless @report.committer == current_user or current_user.session.zone_admin? or current_user.session.site_admin? or current_user.session.zone_supervisor?
    #end
    #if @report.worker_report?
    #  return redirect_to root_path unless @report.committer == current_user or current_user.session.checker? or current_user.session.site_admin?
    #end

    return redirect_to root_path unless @report.committer == current_user or 
                                        current_user.session.checker? or
                                        current_user.session.site_admin? or
                                        current_user.session.zone_supervisor? or
                                        current_user.session.zone_admin?


    #return redirect_to root_path if @report.committer == current_user and @report.status_is_finished?
  end
  def validate_report_template_when_create

    return redirect_to root_path if params[:report][:template_id].nil?
    @template       = Template.find_by_id(params[:report][:template_id])
    #@organization 在validate_organization_visitor中已经计算过了
    if current_user.session.zone_supervisor?
      return redirect_to root_path unless @template.zone_admin == current_user.zone_admin
      return redirect_to root_path unless @current_user.zone_ids.include?(@organization.zone.id)
    else
      return redirect_to root_path unless @template.zone_admin_id == current_user.zone_admin_id
    end
  end
  def validate_report_creater
    #只有worker 和 zone_supervisor才能访问这个 controller
    #否则无法设置 report 的committer
    return redirect_to root_path unless current_user.session.worker? or current_user.session.zone_supervisor?
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
    # @report = Report.includes(:report_records).where(:id=>params[:id])
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
      return redirect_to root_path unless current_user.session.zone_admin? or current_user.session.checker? or current_user.session.site_admin? or current_user.session.zone_supervisor?
    end
  end
  def check_current_user_can_visit_the_organization(organization_id)
    @organization = Organization.find_by_id(organization_id)
    return redirect_to root_path if @organization.nil?
    if current_user.session.zone_admin?
      return redirect_to root_path unless @organization.zone.zone_admin == current_user
    end
    if current_user.session.worker?
      return redirect_to root_path unless current_user.organization_ids.include?(@organization.id)
    end
    if current_user.session.checker?
      return redirect_to root_path unless @organization.checker == current_user
    end
    if current_user.session.zone_supervisor?
      return redirect_to root_path unless current_user.zone_ids.include?(@organization.zone.id)
    end
  end
  def generate_pdf(report)
    Prawn::Document.new do |report_pdf|

      report_pdf.font "#{Prawn::BASEDIR}/data/fonts/simsun.ttf"
      title_1_font_size             = 30
      title_2_font_size             = 20
      section_pad_size              = 15  
      section_line_pad_size         = 10
      section_line_transparent      = 0.2
      # title
      report_pdf.text report.organization.name ,:align => :center,:size => title_1_font_size
      report_pdf.text report.template.name,:align => :center,:size => title_2_font_size
      # part_1:  summary
      report_pdf.pad_top(section_pad_size) do 
        report_pdf.text I18n.t("text.report.summary"),:size => title_2_font_size
      end
      report_pdf.pad(section_line_pad_size) do
        report_pdf.transparent(section_line_transparent) {report_pdf.stroke_horizontal_rule}
      end
      summary_text_items = 
                    [ 
                      I18n.t("text.report.template.name")+":\t" + report.template.name  ,
                      I18n.t("text.report.template.checkpoint_num")+":\t"+report.template.get_check_ponits_num.to_s + "个",
                      I18n.t("text.report.template.finished_checkpoint_num")+":\t"+report.get_finished_check_points_num.to_s + "个",
                      I18n.t("text.report.committer.name")+":\t"+report.committer.name,
                      I18n.t("text.report.reporter_name")+":\t"+report.reporter_name,
                      I18n.t("text.report.created_at")+":\t" + I18n.localize(report.created_at,format: :long),
                      I18n.t("text.report.status.name")+":\t" + report.get_status_text
                     ] 
      summary_text        = ""
      summary_text_items.each_with_index do |s,i|
        summary_text += "#{i+1}.#{s}\n"
      end
      report_pdf.text summary_text,:leading=>10
      report_pdf.move_down 40
      # part_2:  detail
      report_pdf.pad_top(section_pad_size) do 
        report_pdf.text I18n.t("text.report.detail"),:size => title_2_font_size
      end
      report_pdf.pad(section_line_pad_size) do
        report_pdf.transparent(section_line_transparent) {report_pdf.stroke_horizontal_rule}
      end
      detail_table_header = [
                              I18n.t("text.report.check_category"),
                              I18n.t("text.report.check_point"),
                              I18n.t("text.report.check_time")
                            ]
      header_num = 0
      if report.template.check_value.has_boolean_name?
        detail_table_header.push(report.template.check_value.boolean_name)
        header_num +=1
      end
      if report.template.check_value.has_int_name?
        detail_table_header.push(report.template.check_value.int_name)
        header_num +=1
      end
      if report.template.check_value.has_float_name?
        detail_table_header.push(report.template.check_value.float_name)
        header_num +=1
      end
      if report.template.check_value.has_date_name?
        detail_table_header.push(report.template.check_value.date_name)
        header_num +=1
      end
      if report.template.check_value.has_text_name?
        detail_table_header.push(report.template.check_value.text_name)
        header_num +=1
      end
      if report.template.check_value.has_text_with_photo_name?
        detail_table_header.push(report.template.check_value.text_with_photo_name)
        header_num +=1
      end
      check_result  = ""
      tab_num       = 1
      report.template.check_categories.each_with_index do |cc,cci|
        check_points_array   =   cc.check_points
        check_result        +=   "#{cci+1}、#{cc.category}\n"
        check_points_array.each_with_index do |cp,cpi|
          items = report_body_text_item2(report.template.check_value,
                                cp,
                                report.get_report_record_by_check_point_id(cp.id)
                                )
          check_result      += "#{Prawn::Text::NBSP * tab_num * 1}#{cpi}、#{cp.content}\n"
          Rails.logger.debug(items)
          items.each_with_index do |item,item_index|
            check_result += "#{Prawn::Text::NBSP * tab_num * 2}"+ "» " + item[0]+":\n" 
            check_result += "#{Prawn::Text::NBSP * tab_num * 5}"+ item[1]+"\n"
          end
        end
      end
      #report_pdf.text check_result,:leading=>10
      summary_table = [
                        detail_table_header
                      ]

      report.template.check_categories.each_with_index do |cc,cci|
        check_points_array  = cc.check_points
        check_points_num    = check_points_array.size
        next if check_points_num == 0
        #first_check_point   = check_points_array.shift
        check_points_array.each_with_index do |cp,cpi|
          if cpi == 0
            tmp = []
            tmp.push({:content=>cc.category,:rowspan=>check_points_num})
            tmp.concat(self.report_body_text_item(report.template.check_value,
                                           cp,
                                           report.get_report_record_by_check_point_id(cp.id)
                                           )
                    )
            summary_table.push(tmp)
          else
            summary_table.push(self.report_body_text_item(report.template.check_value,
                                                         cp,
                                                         report.get_report_record_by_check_point_id(cp.id)))
          end
        end
      end   

      sumary_table = [
                      [{:content=>"x"*100,:colspan=>3+header_num}],
                      detail_table_header,
                      [{:content=> (I18n.t "text.report.summary"),:colspan=>2}],
                      [( I18n.t "text.report.template.name" ),report.template.name],
                      [( I18n.t "text.report.template.checkpoint_num"),report.template.get_check_ponits_num.to_s]
                     ]
      Rails.logger.debug(summary_table)


      report_pdf.move_down 20
      #report_pdf.stroke_bounds

      report_pdf.table(summary_table,:width=>report_pdf.bounds.width) do 
        cells.padding = 8
        cells.size    = 8
        row(0).background_color ="F0F0F0"
        row(0).border_width = 1.5
        columns(0).align = :center
        columns(0).width = 50
        columns(1).width =100

        row(0).align = :center
      end
      #text "<table><tr><td>xxx</td></tr><tr><td></td></tr></table>"
      #text ( I18n.t "text.report.template.name" )+ report.template.name
      #text report.template.get_check_ponits_num.to_s
      #text report.get_finished_check_points_num.to_s

    end.render
  end

public
  def report_body_text_item(check_value,check_point,report_record)
    r = []
    r.push(check_point.content)
    if report_record.nil?
      r.push("N/A")
    else
      r.push(I18n.localize(report_record.created_at,format: :long))
    end
    if check_value.has_boolean_name?
      if report_record.nil?
        r.push(I18n.t "text.report_record.not_begin")
      else
        r.push(report_record.get_boolean_value)
      end
    end

    if check_value.has_int_name?
      if report_record.nil?
        r.push(I18n.t "text.report_record.not_begin")
      else
        r.push(report_record.get_int_value)
      end
    end

    if check_value.has_float_name?
      if report_record.nil?
        r.push(I18n.t "text.report_record.not_begin")
      else
        r.push(report_record.get_float_value)
      end
    end

    if check_value.has_date_name?
      if report_record.nil?
        r.push(I18n.t "text.report_record.not_begin")
      else
        r.push(report_record.get_date_value)
      end
    end

    if check_value.has_text_name?
      if report_record.nil?
        r.push(I18n.t "text.report_record.not_begin")
      else
        r.push(report_record.get_text_value)
      end
    end

    if check_value.has_text_with_photo_name?
      if report_record.nil?
        r.push(I18n.t "text.report_record.not_begin")
      else
        r.push(report_record.get_text_with_photo_value)
      end
    end
    r
  end
  def report_body_text_item2(check_value,check_point,report_record)
    r = []
    #r.push(check_point.content)
    if report_record.nil?
      r.push([I18n.t("text.report.check_time"),"N/A"])
    else
      r.push([I18n.t("text.report.check_time"),I18n.localize(report_record.created_at,format: :long)])
    end
    if check_value.has_boolean_name?
      if report_record.nil?
        r.push([check_value.boolean_name,I18n.t("text.report_record.not_begin")])
      else
        r.push([check_value.boolean_name,report_record.get_boolean_value])
      end
    end

    if check_value.has_int_name?
      if report_record.nil?
        r.push([check_value.int_name,I18n.t("text.report_record.not_begin")])
      else
        r.push([check_value.int_name,report_record.get_int_value])
      end
    end

    if check_value.has_float_name?
      if report_record.nil?
        r.push([check_value.float_name,I18n.t("text.report_record.not_begin")])
      else
        r.push([check_value.float_name,report_record.get_float_value])
      end
    end

    if check_value.has_date_name?
      if report_record.nil?
        r.push([check_value.date_name,I18n.t("text.report_record.not_begin")])
      else
        r.push([check_value.date_name,report_record.get_date_value])
      end
    end

    if check_value.has_text_name?
      if report_record.nil?
        r.push([check_value.text_name,I18n.t("text.report_record.not_begin")])
      else
        r.push([check_value.text_name,report_record.get_text_value])
      end
    end

    if check_value.has_text_with_photo_name?
      if report_record.nil?
        r.push([check_value.text_with_photo_name,I18n.t("text.report_record.not_begin")])
      else
        r.push([check_value.text_with_photo_name,report_record.get_text_with_photo_value])
      end
    end
    r
  end
end
