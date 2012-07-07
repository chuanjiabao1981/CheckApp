class CreateEquipment < ActiveRecord::Migration
  def change
    create_table :equipment do |t|
      t.string :serial_num
      t.date :expire_date
      t.string :equipment_type
      t.text :des
      t.references :zone_admin

      t.timestamps
    end
    add_index :equipment , :serial_num
  end
end
