class OrganizationWorkerRelation < ActiveRecord::Base
	belongs_to :worker
	belongs_to :organization 
end
