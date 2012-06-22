require 'file_size_validator' 

class MediaInfo < ActiveRecord::Base
  require 'carrierwave/orm/activerecord'
  attr_accessible :photo_path,:video_path,:media_type

  belongs_to :report_record
  mount_uploader :photo_path,MediaInfoPhotoUploader
  mount_uploader :video_path,MediaInfoVideoUploader
  validates :video_path,file_size:{:maximum => 20.megabytes.to_i }

end
