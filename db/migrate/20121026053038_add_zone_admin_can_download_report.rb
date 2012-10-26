class AddZoneAdminCanDownloadReport < ActiveRecord::Migration
  def up
  	add_column :zone_admins,:can_download_report,:boolean,:default=>false
  end

  def down
  	remove_column :zone_admins,:can_download_report
  end
end
