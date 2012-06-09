#encoding:utf-8
class ReportValidator < ActiveModel::Validator
  def validate(record)
    if not record.errors.empty?
      return
    end
    if not record.organization.zone.zone_admin.template_ids.include?(record.template_id)
      record.errors[:template_id]='当前机构没有此模板'
      return
    end
    if record.committer_type == 'ZoneSupervisor'
      if not record.template.for_supervisor?
        record.errors[:committer_id] = '当前人员使用的是自查模板'
        return
      end
    end
    if record.committer_type == 'Worker'
      if not record.template.for_worker?
        record.errors[:committer_id] = '当前人员使用的是督察模板'
        return
      end
      if record.organization_id != record.committer.organization_id
        record.errors[:organization_id] = '当前人员不能提交此机构的模板'
        return
      end
    end
    if record.status != 'new' && record.status !='reject' && record.status != 'finished'
      record.errors[:status] = 'report状态错误'
    end
  end
end

class Report < ActiveRecord::Base
  #attr_accessible :template_id,:organization_id,:reporter_name
  attr_accessible :template_id,:reporter_name
  belongs_to :template,inverse_of: :reports
  belongs_to :organization
  belongs_to :committer,polymorphic:true
  has_many   :report_records, dependent: :destroy


  validates :organization,presence:true
  validates :template,presence:true
  validates :reporter_name,presence:true,length:{maximum:32}
  validates :status,presence:true

  validates_with ReportValidator


  def supervisor_report?
    return true if self.committer_type == 'ZoneSupervisor'
    return false
  end
  def worker_report?
    return true if self.committer_type == 'Worker'
    return false
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
