# == Schema Information
#
# Table name: check_categories
#
#  id          :integer         not null, primary key
#  category    :string(255)
#  des         :string(255)
#  template_id :integer
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

class CheckCategory < ActiveRecord::Base
  attr_accessible :category,:des
  has_many :check_points,:dependent=>:destroy
  belongs_to :template

  validates :category,  presence: true, length:{ maximum:255 } 
  validates :des,length:{maximum:600}
  validates :template_id,presence:true

end
