module ReportsHelper
	def find_report_in_time_range(template,start_time,end_time)
		return Report.where(:created_at=>start_time.to_date..end_time.to_date,:template_id =>template.id)
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
			Rails.logger.debug("finished check points num:" + @finished_check_points_num.to_s)
			Rails.logger.debug("success check points num:"  + @success_check_points_num.to_s)
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
			if report_status.report.supervisor_report?
				@supervisor_report_status_list.push report_status
				@total_org_has_worker_report[report_status.report.organization_id] = "y"
			elsif report_status.report.worker_report?
				@worker_report_status_list.push report_status
				@total_org_has_supervisor_report[report_status.report.organization_id] = "y"
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
			Rails.logger.debug("template check_points num :" +@total_check_points_num.to_s)
			s = 0 
			report_status_list.each do |rs|
				percent = rs.finished_check_points_num/Float(@total_check_points_num)
				Rails.logger.debug(rs.report.template.name + "finished percent:" + percent.to_s)
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
				Rails.logger.debug(rs.report.template.name + "success percent:" + percent.to_s)
				if percent < a and percent >= b or (percent == a and a == 1)
					s = s + 1
				end
			end
			return s
		end
	end
end
