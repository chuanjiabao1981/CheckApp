class CreateZoneSupervisors < ActiveRecord::Migration
  def change
    create_table :zone_supervisors do |t|
      t.string :name
      t.string :des
      t.string :password_digest
      t.references :zone_admin

      t.timestamps
    end
  end
end
