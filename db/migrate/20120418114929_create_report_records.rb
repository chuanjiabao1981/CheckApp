class CreateReportRecords < ActiveRecord::Migration
  def change
    create_table :report_records do |t|
      t.references :report
      t.references :check_point
      t.references :check_category
      t.boolean :boolean_value,default:false
      t.integer :int_value,default:0
      t.float :float_value,default:0.0
      t.date :date_value,default:'2011-12-03'
      t.text :text_value,default:''
      t.string :photo_path
      t.string :video_path

      t.timestamps
    end
    add_index :report_records, :report_id
    add_index :report_records, :check_point_id
  end
end
