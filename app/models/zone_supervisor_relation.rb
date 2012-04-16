class ZoneSupervisorRelation < ActiveRecord::Base
  attr_accessible :zone_supervisor_id
  belongs_to :zone
  belongs_to :zone_supervisor

  validates :zone_id,presence:true
  validates :zone_supervisor,presence:true
end
