class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :name
      t.string :phone
      t.string :address
      t.string :contact
      t.references :zone

      t.timestamps
    end
  end
end
