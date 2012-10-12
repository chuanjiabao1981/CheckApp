class AddTextWithPhotoToZoneAdmin < ActiveRecord::Migration
  def up
  	add_column :zone_admins,:can_text_with_photo,:boolean,:default=>false
  end
  def down
  	remove_column :zone_admins,:can_text_with_photo
  end
end
