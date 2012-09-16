#encoding:utf-8
class OrganizationValidator < ActiveModel::Validator
  def validate(record)
    if (record.zone.zone_admin.get_all_orgs_num + 1) > record.zone.zone_admin.max_org_num
      record.errors[:base] = "您的账户仅能创建#{record.zone.zone_admin.max_org_num}个机构。"
      return 
    end
  end
end
class Organization < ActiveRecord::Base

  JSON_OPTS = {only:[:id,:name,:phone,:contact,:address]}
  attr_accessible :name,:phone,:contact,:address,:checker_attributes,:worker_ids

  belongs_to :zone
  
  has_one :checker,dependent: :destroy,inverse_of: :organization
  #has_one :worker ,dependent: :destroy,inverse_of: :organization
  has_many :organization_worker_relations,dependent: :destroy
  has_many :workers,:through => :organization_worker_relations

  has_many :reports,dependent: :destroy

  validates :name       ,presence:true,length:{maximum:250}
  validates :phone      ,presence:true,length:{maximum:250}
  validates :contact    ,presence:true,length:{maximum:250}
  validates :address    ,presence:true,length:{maximum:250}

  validates_with OrganizationValidator, :on => :create

  accepts_nested_attributes_for :checker

  def build_a_report(report_attribute,committer)
    a = self.reports.build(report_attribute)
    a.committer = committer
    a.set_status_new
    return a
  end
  def get_all_worker_report
    Report.where('organization_id=? and committer_type=?',self.id,'Worker').order("created_at DESC")
  end
  def get_all_finished_worker_report
    Report.where('organization_id=? and committer_type=? and status = ?',self.id,'Worker','finished').order("created_at DESC")
  end
  def get_all_new_worker_report
    Report.where('organization_id=? and committer_type=? and status = ?',self.id,'Worker','new').order("created_at DESC")
  end
  def get_all_supervisor_report
    Report.where('organization_id=? and committer_type=?',self.id,'ZoneSupervisor').order("created_at DESC")
  end
  def get_all_finished_supervisor_report
    Report.where('organization_id=? and committer_type=? and status = ?',self.id,'ZoneSupervisor','finished').order("created_at DESC")
  end
  def get_all_new_supervisor_report
    Report.where('organization_id=? and committer_type=? and status = ?',self.id,'ZoneSupervisor','new').order("created_at DESC")
  end

end
