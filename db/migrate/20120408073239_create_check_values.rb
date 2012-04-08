class CreateCheckValues < ActiveRecord::Migration
  def change
    create_table :check_values do |t|
      t.string :boolean_name
      t.string :int_name
      t.string :float_name
      t.string :date_name
      t.references :template


      t.timestamps
    end
  end
end
