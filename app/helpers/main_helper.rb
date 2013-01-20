module MainHelper
	JSON_PAGINATE_CURRENT_PAGE		=:current_page
	JSON_PAGINATE_PER_PAGE				=:per_page
	JSON_PAGINATE_TOTAL_ENTRIES		=:total_entries
	JSON_WORK_ORGANIZATIONS				=:organizations
	
	def worker_organizations_json(collection)
		paginate_info_json(collection)
		json_add_data(JSON_WORK_ORGANIZATIONS,collection.as_json(Organization::JSON_OPTS))
	end

	def paginate_info_json(collection)
		json_add_data(JSON_PAGINATE_CURRENT_PAGE,@organizations.current_page)
		json_add_data(JSON_PAGINATE_PER_PAGE,@organizations.per_page)
		json_add_data(JSON_PAGINATE_TOTAL_ENTRIES,@organizations.total_entries)
	end
end
