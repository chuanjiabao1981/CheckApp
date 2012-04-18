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
    if record.status != 'new' && record.status !='reject' && record.status != 'done'
      record.errors[:status] = 'report状态错误'
    end
  end
end

class Report < ActiveRecord::Base
  attr_accessible :template_id,:organization_id,:reporter_name
  belongs_to :template,inverse_of: :reports
  belongs_to :organization
  belongs_to :committer,polymorphic:true
  has_many   :report_records, dependent: :destroy


  validates :organization,presence:true
  validates :template,presence:true
  validates :reporter_name,presence:true,length:{maximum:32}
  validates :status,presence:true

  validates_with ReportValidator
end
