#encoding:utf-8
# == Schema Information
#
# Table name: check_points
#
#  id                :integer         not null, primary key
#  content           :text
#  check_category_id :integer
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#
class VideoPhotoNumValidator < ActiveModel::Validator
  def validate(record)
    if not record.errors.empty?
      return
    end
    #Rails.logger.debug("#{record.can_photo}")
    #Rails.logger.debug("#{record.check_category.template.get_photo_check_point_num}")
    #Rails.logger.debug("#{record.check_category.template.zone_admin.template_max_photo_num}")
    #Rails.logger.debug("#{record.can_video}")
    #Rails.logger.debug("#{record.check_category.template.get_video_check_point_num}")
    #Rails.logger.debug("#{record.check_category.template.zone_admin.template_max_video_num}")

    # record.check_category.template.get_photo_check_point_num
    if record.can_photo?
      # Rails.logger.debug("Factory:Can photo [in model]")
    	if record.check_category.template.zone_admin.template_max_photo_num < (record.check_category.template.get_photo_check_point_num + 1)
    	  # Rails.logger.debug("Factory:photoValidate[in model]")
    	  # Rails.logger.debug("#{record.check_category.template.get_photo_check_point_num}")
    	  record.errors[:base]="您的账户仅能创建#{record.check_category.template.zone_admin.template_max_photo_num}个带图像的检查点"
    	  return
    	end
	  end
    if record.can_video?
    	if record.check_category.template.zone_admin.template_max_video_num < (record.check_category.template.get_video_check_point_num + 1)
          # Rails.logger.debug("videoValidate")
      		record.errors[:base]="您的账户仅能创建#{record.check_category.template.zone_admin.template_max_video_num}个带视频的检查点"
      		return
    	end
	  end
  end
end

class CheckPoint < ActiveRecord::Base
  JSON_OPTS = {only:[:id,:content,:can_photo,:can_video]}
  attr_accessible :content,:can_photo,:can_video
  belongs_to :check_category
  validates  :check_category_id,presence:true
  validates  :content,presence:true,length:{maximum:1800} 
  validates_with VideoPhotoNumValidator

  has_many :report_records,dependent: :destroy

end
