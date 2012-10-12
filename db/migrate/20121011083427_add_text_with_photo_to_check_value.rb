class AddTextWithPhotoToCheckValue < ActiveRecord::Migration
  def up
  	add_column :check_values,:text_with_photo_name,:string
  end
  def down
  	remove_column :check_values,:text_with_photo_name
  end
end
