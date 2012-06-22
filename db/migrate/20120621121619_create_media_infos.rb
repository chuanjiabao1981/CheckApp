class CreateMediaInfos < ActiveRecord::Migration
  def up 
    create_table :media_infos do |t|
      t.string :video_path
      t.string :photo_path
      t.string :media_type
      t.references :report_record
      t.timestamps
    end
    add_column :zone_admins,:check_point_photo_num,:integer,:default=>2
    add_column :zone_admins,:check_point_video_num,:integer,:default=>1
    v_n = 0
    p_n = 0
    ReportRecord.all.each do |t|
    	if not t.video_path.nil? and not t.video_path.blank?
    		video_path = "#{Rails.root}/public/#{t.video_path.to_s}"
    	  	if FileTest::exist?(video_path)
    	  		a = MediaInfo.new
    	  		a.report_record_id 			= t.id
    	  		a.media_type			    = 'v'
    	  		# a.save
    	  		a.video_path       			= File.open(video_path)
    	  		a.save
    	  		# printf("%s,%s\n",video_path,Pathname.new(video_path).basename)
    	  		v_n 			   			= v_n + 1
    	  	end
    	end
    end
    puts "==============="
    ReportRecord.all.each do |t|
    	if not t.photo_path.nil? and not t.photo_path.blank?
    		photo_path = "#{Rails.root}/public/#{t.photo_path.to_s}"
    		if FileTest::exist?(photo_path)
    			a = MediaInfo.new
    			a.report_record_id 			= t.id
    			a.media_type			   	= 'p'
    			# a.save
    			a.photo_path       			= File.open(photo_path)
    			a.save
    			# printf("%s,%s\n",photo_path,Pathname.new(photo_path).basename)
    			p_n                			= p_n + 1
    		end
    	end
    end
    printf("%d,%d\n",v_n,MediaInfo.where("media_type=?","v").size)
    printf("%d,%d\n",p_n,MediaInfo.where("media_type=?","p").size)
    MediaInfo.where("media_type=?","p").each do |m|
    	puts m.photo_path
    end
    MediaInfo.where("media_type=?","v").each do |m|
    	puts m.video_path
    end

  end
  def down
  	drop_table :media_infos
  	remove_column :zone_admins,:check_point_photo_num
  	remove_column :zone_admins,:check_point_video_num
  end	
end
