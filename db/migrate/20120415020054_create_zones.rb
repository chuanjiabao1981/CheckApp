class CreateZones < ActiveRecord::Migration
  def change
    create_table :zones do |t|
      t.string :name
      t.string :des
      t.references :zone_admin

      t.timestamps
    end
  end
end
