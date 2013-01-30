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
    	if record.check_category.template.zone_admin.template_max_photo_num < (record.check_category.template.get_photo_check_point_num(record.id))
    	  # Rails.logger.debug("Factory:photoValidate[in model]")
    	  # Rails.logger.debug("#{record.check_category.template.get_photo_check_point_num}")
    	  record.errors[:base]="您的账户仅能创建#{record.check_category.template.zone_admin.template_max_photo_num}个带图像的检查点"
    	  return
    	end
	  end
    if record.can_video?
    	if record.check_category.template.zone_admin.template_max_video_num < (record.check_category.template.get_video_check_point_num(record.id))
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

  def as_json(option={})
    Rails.logger.debug(option)
    json = super(option)
    report_record = nil
    if not option[:report_records].nil?    
      option[:report_records].each do |rr|
        Rails.logger.debug(rr.check_category_id)
        if rr.check_point_id == self.id
          Rails.logger.debug(rr.check_category_id)
          report_record = rr
          break
        end
      end
    end
    if not report_record.nil?
      json[:report_record]= report_record.as_json(include:{media_infos:{}})
      json[:media_infos]  = report_record.media_infos.as_json()
    end
    json
  end

end
