# == Schema Information
#
# Table name: templates
#
#  id             :integer         not null, primary key
#  name           :string(255)
#  for_supervisor :boolean
#  for_worker     :boolean
#  admin_id       :integer
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#  can_video      :boolean         default(FALSE)
#  can_photo      :boolean         default(FALSE)
#

class Template < ActiveRecord::Base
  attr_accessible :name,:for_supervisor,:for_worker,:check_value_attributes
  belongs_to :zone_admin
  has_one :check_value,dependent:  :destroy,inverse_of: :template

  has_many :check_categories,dependent: :destroy

  validates :name,  presence: true, length:{ maximum:128 } ,uniqueness: { case_sensitive: false }
  validates :zone_admin_id,presence:true
  validates :check_value,presence:true
  
  accepts_nested_attributes_for :check_value

end
