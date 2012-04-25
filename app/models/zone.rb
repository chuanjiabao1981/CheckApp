class Zone < ActiveRecord::Base

  JSON_OPTS       = {only:[:name],include:{organizations:Organization::JSON_OPTS}}
  attr_accessible :name,:des,:zone_supervisor_ids

  belongs_to :zone_admin

  has_many   :zone_supervisor_relations,:dependent=>:destroy
  has_many   :zone_supervisors,:through => :zone_supervisor_relations
  has_many   :organizations, :dependent=>:destroy
  
  validates :name,length:{maximum:250},presence:true
  validates :des, length:{maximum:400}
  validates :zone_admin_id,presence:true

end
