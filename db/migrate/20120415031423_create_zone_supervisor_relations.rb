class CreateZoneSupervisorRelations < ActiveRecord::Migration
  def change
    create_table :zone_supervisor_relations do |t|
      t.references :zone
      t.references :zone_supervisor

      t.timestamps
    end
  end
end
