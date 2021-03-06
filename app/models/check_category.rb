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
  JSON_OPTS = {only:[:id,:category,:des],include:{check_points:CheckPoint::JSON_OPTS}}
  attr_accessible :category,:des
  has_many :check_points,:dependent=>:destroy
  belongs_to :template

  validates :category,  presence: true, length:{ maximum:255 } 
  validates :des,length:{maximum:600}
  validates :template_id,presence:true

  def as_json(options={})
  	json = super(options)
  	if not options[:report].nil?
  	  json[:finished_check_points_num] = options[:report].get_finished_check_points_num_by_check_category(self.id)
  	  json[:check_points_num]		   = self.check_points.size
  	end
  	json
  end

end
