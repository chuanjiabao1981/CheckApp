class CreateSessions < ActiveRecord::Migration
  def change
    create_table :sessions do |t|
      t.string :remember_token
      t.references :login ,:polymorphic => true

      t.timestamps
    end
    add_index :sessions, :login_id
  end
end
