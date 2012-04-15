class Zone < ActiveRecord::Base
  attr_accessible :name,:des
  belongs_to :zone_admin,class_name:'User',foreign_key:'zone_admin_id'
  has_many   :zone_supervisor_relations,:dependent=>:destroy
  has_many   :zone_supervisors,:through => :zone_supervisor_relations,source:'zone_supervisor_id'
  has_many   :organizations, :dependent=>:destroy
  
  validates :name,length:{maximum:250},presence:true
  validates :des, length:{maximum:400}
  validates :zone_admin_id,presence:true
end
