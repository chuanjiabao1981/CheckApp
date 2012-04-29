class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.string :reporter_name
      t.references :template
      t.references :organization
      t.references :committer ,polymorphic:true
      t.string :status

      t.timestamps
    end
    add_index :reports, :template_id
    add_index :reports, :organization_id
  end
end
