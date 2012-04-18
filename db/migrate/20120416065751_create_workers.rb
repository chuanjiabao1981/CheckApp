class CreateWorkers < ActiveRecord::Migration
  def change
    create_table :workers do |t|
      t.string :name
      t.string :des
      t.string :password_digest
      t.references :organization

      t.timestamps
    end
    add_index :workers, :organization_id
  end
end
