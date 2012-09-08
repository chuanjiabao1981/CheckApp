class Location < ActiveRecord::Base
	belongs_to :zone_admin
	has_many   :reports	  ,dependent: :destroy

	validates :name,  presence: true, length:{ maximum:200 }
	validates :des,	  length:{ maximum:600}
end
