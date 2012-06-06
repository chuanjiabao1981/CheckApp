#encoding:utf-8
require 'file_size_validator' 

class ReportRecord < ActiveRecord::Base
  require 'carrierwave/orm/activerecord'

  attr_accessible :check_point_id,:int_value,:float_value,:text_value,:boolean_value,:photo_path,:video_path,:date_value
  belongs_to :report
  belongs_to :check_point#,inverse_of: :report_records
  belongs_to :check_category


  validates :int_value, numericality: { :only_integer => true }
  validates :float_value,numericality:true
  validates :text_value,length:{maximum:1200}
  validates :check_point,presence:true
  validates :check_category,presence:true
  mount_uploader :photo_path,CheckPhotoUploader
  mount_uploader :video_path,CheckVideoUploader
  #这个留给video用
  #validates :video_path,file_size:{:maximum => 1.kilobytes.to_i}
  validates :video_path,file_size:{:maximum => 20.megabytes.to_i }

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
  def get_video_path
    return self.video_path
  end
  def get_photo_path
    return self.photo_path
  end
end
