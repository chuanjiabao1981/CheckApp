class AddTextWithPhotoToReportRecords < ActiveRecord::Migration
  def up
  	add_column :report_records,:text_with_photo_value,:string
  end
  def down
  	remove_column :report_records,:text_with_photo_value
  end
end
