class AddMaxOrgAndMaxSuperAndMaxBackUp < ActiveRecord::Migration
  def up
  	add_column :zone_admins,:max_org_num,:integer,:default=>5
  	add_column :zone_admins,:max_zone_supervisor_num,:integer,:default=>5
  	add_column :zone_admins,:max_backup_month,:integer,:default=>10
  end

  def down
  	remove_column :zone_admins,:max_org_num
  	remove_column :zone_admins,:max_zone_supervisor_num
  	remove_column :zone_admins,:max_backup_month
  end
end
