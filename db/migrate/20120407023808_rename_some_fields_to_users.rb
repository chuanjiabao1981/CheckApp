class RenameSomeFieldsToUsers < ActiveRecord::Migration
  def up
    change_table :users do |t|
      t.rename :supervisor,:zone_supervisor
      t.rename :checker,   :org_checker
      t.rename :worker,    :org_worker
    end
  end

  def down
    change_table :users do |t|
      t.rename :zone_supervisor,:supervisor
      t.rename :org_checker,:checker
      t.rename :org_worker,:worker
    end
  end
end
