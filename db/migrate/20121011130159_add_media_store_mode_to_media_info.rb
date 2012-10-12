class AddMediaStoreModeToMediaInfo < ActiveRecord::Migration
  def up
  	add_column :media_infos,:media_store_mode,:string,:default=>'local'
  	MediaInfo.all.each do |m|
  		print m.photo_path,",",m.media_store_mode,"\n"
  		m.media_store_mode = 'local'
  		m.save
  	end
  	print "==========================\n"
  	MediaInfo.all.each do |m|
  		print m.photo_path,",",m.media_store_mode,"\n"
  	end
  end

  def down
  	remove_column :media_infos,:media_store_mode
  end
end
