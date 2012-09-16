class CreateOrganizationWorkerRelations < ActiveRecord::Migration
  def change
    create_table :organization_worker_relations do |t|
      t.references :organization
      t.references :worker
      t.timestamps
    end
    add_index :organization_worker_relations,:worker_id
    add_index :organization_worker_relations,:organization_id

  end
end
