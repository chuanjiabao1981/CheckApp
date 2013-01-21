module MainHelper

	JSON_WORK_ORGANIZATIONS				=:organizations
	JSON_ZONE_SUPERVISOR_ZONES			=:zones
	
	def worker_organizations_json(collection)
		paginate_info_json(collection)
		json_add_data(JSON_WORK_ORGANIZATIONS,collection.as_json(Organization::JSON_OPTS))
	end

	def zone_supervisor_zones_json(collection)
		paginate_info_json(collection)
		json_add_data(JSON_ZONE_SUPERVISOR_ZONES,collection.as_json(Zone::JSON_OPTS))
	end


	
end
