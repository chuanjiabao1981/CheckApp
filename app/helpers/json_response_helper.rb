module JsonResponseHelper
	def json_response
		@_json_response ||= {}
	end
	def json_errors(errors_data)
		json_response[JsonConstants::JSON_ERRORS]=errors_data
		return json_response
	end
	def json_warns(warns_data)
		json_response[JsonConstants::JSON_WARNS]=warns_data
	end
	def json_base_warns(base_warn_msg)
		json_warns({JsonConstants::JSON_WARNS_BASE => [base_warn_msg]})
	end
	def json_base_errors(base_error_msg)
    	return json_errors({ JsonConstants::JSON_ERRORS_BASE => [ base_error_msg ]})
  	end
	def json_add_data(key,value)
		json_response[key]=value
		return json_response
	end
end