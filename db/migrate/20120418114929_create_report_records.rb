class CreateReportRecords < ActiveRecord::Migration
  def change
    create_table :report_records do |t|
      t.references :report
      t.references :check_point
      t.boolean :boolean_value
      t.integer :int_value
      t.float :float_value
      t.date :date_value
      t.text :text_value
      t.string :photo_path
      t.string :video_path

      t.timestamps
    end
    add_index :report_records, :report_id
    add_index :report_records, :check_point_id
  end
end
