module OrganizationsHelper
	JSON_ORGANIZATIONS=:organizations

	def organization_index_json(collection)
		paginate_info_json(collection)
		json_add_data(JSON_ORGANIZATIONS,collection.as_json(Organization::JSON_OPTS))
	end
end
