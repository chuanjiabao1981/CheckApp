#encoding:utf-8
require 'file_size_validator' 

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
      if not record.committer.organization_ids.include?(record.organization_id)
        record.errors[:organization_id] = '当前人员不能提交此机构的模板'
        return
      end
    end
    if record.status != 'new' && record.status !='reject' && record.status != 'finished'
      record.errors[:status] = 'report状态错误'
    end
  end
end

class ReportRecord < ActiveRecord::Base
  require 'carrierwave/orm/activerecord'

  attr_accessible :check_point_id,:int_value,:float_value,:text_value,:boolean_value,:date_value,:media_infos_attributes
  belongs_to :report
  belongs_to :check_point#,inverse_of: :report_records
  belongs_to :check_category


  validates :int_value, numericality: { :only_integer => true }
  validates :float_value,numericality:true
  validates :text_value,length:{maximum:1200}
  validates :check_point,presence:true
  validates :check_category,presence:true
  has_many  :media_infos,dependent: :destroy
  # mount_uploader :photo_path,CheckPhotoUploader
  # mount_uploader :video_path,CheckVideoUploader

  accepts_nested_attributes_for :media_infos

  #这个留给video用
  #validates :video_path,file_size:{:maximum => 20.megabytes.to_i }

  def build_video_media
    a                 = self.media_infos.build
    a.media_type      = "v"
  end
  def build_photo_media
    a                 = self.media_infos.build
    a.media_type      = "p"
  end
  def get_boolean_value
    return "是" if self.boolean_value
    return "否" if not self.boolean_value
  end
  def get_float_value
    return self.float_value.to_s
  end
  def get_int_value
    return self.int_value.to_s
  end
  def get_date_value
    return self.date_value.to_s
  end
  def get_text_value
    return self.text_value
  end
end
