class CreateCheckPoints < ActiveRecord::Migration
  def change
    create_table :check_points do |t|
      t.text :content
      t.references :check_category

      t.timestamps
    end
  end
end
