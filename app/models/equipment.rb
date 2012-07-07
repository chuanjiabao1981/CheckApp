class Equipment < ActiveRecord::Base
	attr_accessible :serial_num,:expire_date,:equipment_type,:des,:zone_admin_id
	belongs_to :zone_admin

	validates :serial_num,  presence: true, length:{ maximum:254 }, uniqueness: { case_sensitive: false }
	validates :expire_date, presence: true
	validates :equipment_type ,length:{maximum:254}
end
