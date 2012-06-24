class RemoveVideoPathAndPhotoPathFromReportRecord < ActiveRecord::Migration
  def up
	remove_column :report_records,:video_path
	remove_column :report_records,:photo_path
  end

  def down
  	add_column :report_records,:video_path
  	add_column :report_records,:photo_path
  end
end
