class AddMediaCaption < ActiveRecord::Migration
  def up
  	add_column :zone_admins,	:can_media_caption,:boolean,:default=>false
  	add_column :templates,   	:media_caption_enable,:boolean,:default=>false
  	add_column :media_infos,	:photo_caption,:string,:default=>""
  	add_column :media_infos,	:video_caption,:string,:default=>""
  end

  def down
  	remove_column :media_infos,		:video_caption
  	remove_column :media_infos,		:photo_caption
  	remove_column :templates,   	:media_caption_enable
  	remove_column :zone_admins,		:can_media_caption
  end
end
