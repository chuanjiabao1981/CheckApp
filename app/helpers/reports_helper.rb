module ReportsHelper
	WORKER_BRANCH 				= 1
	SUPERVISOR_BRANCH			= 2
	NONE_BRANCH					= -1
	JSON_REPORT					= :reports
	JSON_REPORT_CATEGORIES		= :categories
	JSON_REPORT_TEMPLATES		= :templates
	JSON_REPORT_LOCATIONS		= :locations
	JSON_REPORT_ID				= :report_id
	def reports_json(collection)
		paginate_info_json(collection)
		json_add_data(JSON_REPORT,collection.as_json(Report::JSON_OPTS))
	end

	def report_check_categories_json(report)
		json_add_data(JSON_REPORT_CATEGORIES,report.template.check_categories.as_json(report:report))
	end

	def report_detail_json(report)
		report_records=ReportRecord.where(report_id:report.id)
        json_add_data(:check_value,report.template.check_value.as_json)
        json_add_data(:check_categories,report.template.check_categories.as_json(include:{check_points:{media_num:true}}))
        json_add_data(:report_records,report_records.as_json)
	end

	def report_new_json(templates,locations)
		json_add_data(JSON_REPORT_TEMPLATES,templates.as_json(Template::JSON_OPTS_SIMPLE))
		json_add_data(JSON_REPORT_LOCATIONS,locations.as_json(Location::JSON_OPTS))
	end

	def report_id_json(report)
		json_add_data(:report_id,report.id)
	end
	def find_report_in_time_range(template,start_time,end_time)
		return Report.where(:created_at=>start_time.to_date..end_time.to_date,:template_id =>template.id)
	end
	def get_report_branch report
		if not report.nil?
			if report.supervisor_report?
				return SUPERVISOR_BRANCH
			end
			if report.worker_report?
				return WORKER_BRANCH
			end
			return NONE_BRANCH
		end
		if controller_name == 'organizations' and action_name == 'worker_reports'
			return WORKER_BRANCH
		end
		if controller_name == 'organizations' and action_name == 'supervisor_reports'
			return SUPERVISOR_BRANCH
		end
		if controller_name == 'reports' and action_name == 'supervisor_report'
			return SUPERVISOR_BRANCH
		end
		if controller_name == 'reports' and action_name == 'worker_report'
			return WORKER_BRANCH
		end
	end
	class ReportStatus
		attr_accessor :finished_check_points_num,:success_check_points_num,:report
		def initialize report
			@report 									= report
			init
		end

		private
		def init
			@finished_check_points_num = @report.get_finished_check_points_num
			@success_check_points_num  = @report.get_success_check_points_num
			# Rails.logger.debug("finished check points num:" + @finished_check_points_num.to_s)
			# Rails.logger.debug("success check points num:"  + @success_check_points_num.to_s)
		end
	end

	class ReportStatistics
		def initialize template
			@template 																= template
			@supervisor_report_status_list 						= []
			@worker_report_status_list								=	[]
			@total_check_points_num										= @template.get_check_ponits_num
			@total_org_has_worker_report	 						= Hash.new
			@total_org_has_supervisor_report					= Hash.new
		end

		def add_a_report_status report_status
			# Rails.logger.debug("worker len:"+@total_org_has_worker_report.length.to_s)
			# Rails.logger.debug("super len:" +@total_org_has_supervisor_report.length.to_s)
			if report_status.report.supervisor_report?
				@supervisor_report_status_list.push report_status
				@total_org_has_supervisor_report[report_status.report.organization_id] = "y"
				# Rails.logger.debug("supervisor report org:"+report_status.report.organization.name)
			elsif report_status.report.worker_report?
				@worker_report_status_list.push report_status
				@total_org_has_worker_report[report_status.report.organization_id] = "y"
				# Rails.logger.debug("worker report org:"+report_status.report.organization.name)
			end
		end

		def get_total_org_has_supervisor_report_num
			return @total_org_has_supervisor_report.length
		end
		def get_total_org_has_worker_report_num
			return @total_org_has_worker_report.length
		end
		def get_total_check_points_num
			return @total_check_points_num
		end
		def get_total_supervisor_report_num
			@supervisor_report_status_list.length
		end

		def get_total_worker_report_num
			@worker_report_status_list.length
		end

		# [a,b)
		def get_supervisor_report_num_according_to_finished_percent a,b
		  return get_report_num_according_to_finished_percent @supervisor_report_status_list,a,b
		end
		def get_supervisor_report_num_according_to_success_percent a,b
			return get_report_num_according_to_success_percent @supervisor_report_status_list,a,b
		end
		def get_worker_report_num_according_to_finished_percent a,b
			return get_report_num_according_to_finished_percent @worker_report_status_list,a,b
		end
		def get_worker_report_num_according_to_success_percent a,b
			return get_report_num_according_to_success_percent @worker_report_status_list,a,b
		end

		private 
		def get_report_num_according_to_finished_percent report_status_list,a,b
			return 0 if @total_check_points_num == 0
			# Rails.logger.debug("template check_points num :" +@total_check_points_num.to_s)
			s = 0 
			report_status_list.each do |rs|
				percent = rs.finished_check_points_num/Float(@total_check_points_num)
				# Rails.logger.debug(rs.report.template.name + "finished percent:" + percent.to_s)
				if (percent < a and percent >=b) or (percent == a and a == 1)
					s = s + 1
				end
			end
			return s
		end
		def get_report_num_according_to_success_percent report_status_list,a,b
			return 0 if @total_check_points_num == 0
			Rails.logger.debug("template check_points num :" +@total_check_points_num.to_s)
			s = 0
			report_status_list.each do |rs|
				percent = rs.success_check_points_num/Float(@total_check_points_num)
				Rails.logger.debug("success num:" + rs.success_check_points_num.to_s)
				Rails.logger.debug(rs.report.template.name + "success percent:" + percent.to_s)
				if percent < a and percent >= b or (percent == a and a == 1)
					s = s + 1
				end
			end
			return s
		end
	end
end
