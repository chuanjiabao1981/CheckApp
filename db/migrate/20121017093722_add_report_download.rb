class AddReportDownload < ActiveRecord::Migration
  def up
  	add_column :reports,:download_num,:int,:default=>0

  end

  def down
  	remove_column :reports,:download_num
  end
end
