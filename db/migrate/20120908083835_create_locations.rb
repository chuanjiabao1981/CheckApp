class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :name
      t.text :des
      t.references :zone_admin
      
      t.timestamps
    end
  end
end
