class CreateCheckCategories < ActiveRecord::Migration
  def change
    create_table :check_categories do |t|
      t.string :category
      t.string :des
      t.references :template

      t.timestamps
    end
  end
end
