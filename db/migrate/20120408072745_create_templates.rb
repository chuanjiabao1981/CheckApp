class CreateTemplates < ActiveRecord::Migration
  def change
    create_table :templates do |t|
      t.string :name
      t.boolean :for_supervisor
      t.boolean :for_checker
      t.references :admin

      t.timestamps
    end
  end
end
