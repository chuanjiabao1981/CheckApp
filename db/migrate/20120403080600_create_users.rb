class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :password_digest
      t.string :des
      t.boolean :site_admin, :default=>false
      t.boolean :admin,      :default=>false
      t.boolean :supervisor,  :default=>false
      t.boolean :worker,      :default=>false
      t.boolean :checker,     :default=>false
      t.references :admin,

      t.timestamps
    end
  end
end
