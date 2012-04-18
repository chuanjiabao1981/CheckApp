class CreateCheckers < ActiveRecord::Migration
  def change
    create_table :checkers do |t|
      t.string :name
      t.string :des
      t.string :password_digest
      t.references :organization

      t.timestamps
    end
    add_index :checkers, :organization_id
  end
end
