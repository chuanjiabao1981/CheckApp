class RenameAdminToZoneAdminToUsers < ActiveRecord::Migration
  def up
    change_table :users do |t|
      t.rename :admin,:zone_admin
    end
  end

  def down
    change_table :users do |t|
      t.rename :zone_admin,:admin
    end

  end
end
