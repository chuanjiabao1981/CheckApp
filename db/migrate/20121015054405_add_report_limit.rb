class AddReportLimit < ActiveRecord::Migration
  def up
		add_column :zone_admins,:max_worker_report_num,:int,:default=>50
		add_column :zone_admins,:max_supervisor_report_num,:int,:default=>10
  end

  def down
  	remove_column :zone_admins,:max_worker_report_num
  	remove_column :zone_admins,:max_supervisor_report_num
  end
end
