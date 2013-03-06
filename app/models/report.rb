#encoding:utf-8
class ReportValidator < ActiveModel::Validator
  def validate(record)
    if not record.errors.empty?
      return
    end
    if not record.location_id.nil?
      if not record.organization.zone.zone_admin.location_ids.include?(record.location_id)
        record.errors[:location_id]=I18n.t('errors.report.location_not_valid')
      end
    end
    if not record.organization.zone.zone_admin.template_ids.include?(record.template_id)
      record.errors[:template_id]= I18n.t('errors.report.template_not_valid')
      return
    end
    if record.committer_type == 'ZoneSupervisor'
      if not record.template.for_supervisor?
        record.errors[:committer_id] = '当前人员使用的是自查模板'
        return
      end
      if not record.committer.zone_ids.include?(record.organization.zone.id)
        record.errors[:base]= I18n.t('errors.session.type_wrong')
        return 
      end
    end
    if record.committer_type == 'Worker'
      if not record.template.for_worker?
        record.errors[:committer_id] = '当前人员使用的是督察模板'
        return
      end
      if not record.committer.organization_ids.include?(record.organization_id)
        record.errors[:base] = I18n.t('errors.session.type_wrong')
        return
      end
    end
    if record.status != 'new' && record.status !='reject' && record.status != 'finished'
      record.errors[:status] = I18n.t('errors.report.status_not_valid')
    end
  end
end
class ReportNumValidator < ActiveModel::Validator
  def validate(record)
    if not record.errors.empty?
      return 
    end
    if record.supervisor_report?
      if (record.template.zone_admin.get_all_supervisor_report_num + 1) >  record.template.zone_admin.max_supervisor_report_num 
        #record.errors[:base] = "您的账户仅能创建#{record.template.zone_admin.max_supervisor_report_num}个督察报告。"
        record.errors[:base] = I18n.t('errors.report.supervisor_report_num_exceed',:max_supervisor_report_num =>record.template.zone_admin.max_supervisor_report_num)
        return 
      end  
    end
    if record.worker_report?
      if (record.template.zone_admin.get_all_worker_report_num + 1) > record.template.zone_admin.max_worker_report_num
        #record.errors[:base] = "您的账户仅能创建#{record.template.zone_admin.max_worker_report_num}个巡查报告。"
        record.errors[:base] = I18n.t('errors.report.worker_report_num_exceed',:max_worker_report_num => record.template.zone_admin.max_worker_report_num)
        return 
      end
    end
  end
end

class Report < ActiveRecord::Base
  JSON_OPTS={
              only:[:id,:committer_type,:reporter_name,:status,:created_at],
              include:{
                        template:{
                                   only:[:id,:name]
                                  },
                        location:{
                                  only:[:id,:name]
                        }
                      }
          }
  #attr_accessible :template_id,:organization_id,:reporter_name
  attr_accessible :template_id,:reporter_name,:location_id
  belongs_to :template,inverse_of: :reports
  belongs_to :organization
  belongs_to :location
  belongs_to :committer,polymorphic:true
  has_many   :report_records, dependent: :destroy


  validates :organization,presence:true
  # 这里没有使用 validates :template,presence:true
  # 原因:
  # 客户端需要知道提交的字段中到底是哪个出错了，需要明确的给出是 template_id。如果使用:template则只能给出report[template]='xxxxx'的错误
  # 但是，validates template_id仅能保证template_id这个值存在，但是不能保证template是存在的。所以要单独写一个Validator 判断template_id是否合法
  # ReportValidator 中的record.organization.zone.zone_admin.template_ids.include?(record.template_id) 等价与判断template是否合法，所以就不单独写了
  validates :template_id,presence:true
  #validates :template,presence:true
  validates :reporter_name,presence:true,length:{maximum:32}
  validates :status,presence:true

  validates_with ReportValidator
  validates_with ReportNumValidator, :on => :create


  def self.statistics(query)
    reports = Report.includes(:template).select("template_id,DATE_FORMAT(reports.created_at,'%X-%V') AS created_x,count(*) AS report_num_per_x").where("organization_id=? and template_id in (?)",query[:organization_id],query[:template_ids]).group('created_x,template_id')
    reports
  end
  def supervisor_report?
    return true if self.committer_type == 'ZoneSupervisor'
    return false
  end
  def worker_report?
    return true if self.committer_type == 'Worker'
    return false
  end
  def get_report_type_text
    if self.supervisor_report?
      return I18n.t "text.report.type.supervisor"
    elsif self.worker_report?
      return I18n.t "text.report.type.worker"
    else
      return I18n.t "text.report.type.err"
    end
  end
  def get_status_text
    if self.status_is_finished?
      return I18n.t "text.report.status.finished"
    elsif self.status_is_new?
      return I18n.t "text.report.status.new"
    else
      return I18n.t "text.report.status.error"
    end
  end
  def status_is_finished?
    return true if self.status == 'finished'
    return false
  end
  def status_is_new?
    return true if self.status == 'new'
    return false
  end
  def get_finished_check_points_num
    return self.report_records.size
  end
  def get_success_check_points_num
    s = 0
    self.report_records.each do |rr|
      s = s+1 if rr.boolean_value
      Rails.logger.debug("boolean_value:"+rr.boolean_value.to_s)
    end
    return s
  end
  def get_finished_check_points_num_by_check_category(check_category_id)
    s = 0
    self.report_records.each do |rr|
      s = s+1 if rr.check_category_id.to_s == check_category_id.to_s
    end
    return s
  end
  def get_report_record_id_by_check_point_id(check_point_id)
    self.report_records.each do|rr|
      return rr.id if rr.check_point_id.to_s == check_point_id.to_s
    end
    return 
  end
  def get_report_record_by_check_point_id(check_point_id)
    self.report_records.each do|rr|
      return rr if rr.check_point_id.to_s == check_point_id.to_s
    end
    return
  end
  def check_point_is_done?(check_point_id)
    self.report_records.each do |rr|
      return true if rr.check_point_id.to_s == check_point_id.to_s
    end
    return false
  end
  def set_status_new
    self.status = 'new'
  end
  def set_status_finished
    self.status = 'finished'
  end
  def finished_check_points_num
    n = 0
    self.template.check_categories.each do |cc|
      n += get_finished_check_points_num_by_check_category(cc.id)
    end
    return n
  end
  def finished?
    return true if self.finished_check_points_num == self.template.get_check_ponits_num
  end
end
