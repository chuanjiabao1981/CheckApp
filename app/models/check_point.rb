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

class CheckPoint < ActiveRecord::Base
  attr_accessible :content,:can_photo,:can_video
  belongs_to :check_category
  validates  :check_category_id,presence:true
  validates  :content,presence:true,length:{maximum:1800} 

  has_many :report_records,dependent: :destroy
end
