class AddLocationReferenceToReports < ActiveRecord::Migration
  def up
  	add_column :reports,:location_id,:integer
  end

  def down
  	remove_column :reports,:location
  end
end
