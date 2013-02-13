require 'file_size_validator' 



class MediaInfo < ActiveRecord::Base
  include ReportRecordsHelper

  require 'carrierwave/orm/activerecord'
  attr_accessible :photo_path,:video_path,:media_type,:media_store_mode,:photo_caption,:video_caption,
                  ReportRecordsHelper::JSON_BASE64_PHOTO,ReportRecordsHelper::JSON_UPLOAD_ORI_FILE_NAME

  belongs_to :report_record
  mount_uploader :photo_path,MediaInfoPhotoUploader
  mount_uploader :video_path,MediaInfoVideoUploader
  validates :video_path,file_size:{:maximum => 20.megabytes.to_i }


  def as_json(options={})
    json=super(options)
    json[:photo_path]=self.photo_path.to_s
    json[:video_path]=self.video_path.to_s
    json
  end
  def checkpointPhoto?
  	return true if self.media_type == Rails.application.config.MediaTypeCheckPointPhoto
  	return false
  end
  def checkpointVideo?
  	return true if self.media_type	== Rails.application.config.MediaTypeCheckPointVideo
  	return false
  end

  def textWithPhoto?
  	return true if self.media_type == Rails.application.config.MediaTypeTextWithPhoto
  	return false
  end
  def textWithVideo?
  	return true if self.media_type == Rails.application.config.MediaTypeTextWithVideo
  	return false
  end
end
