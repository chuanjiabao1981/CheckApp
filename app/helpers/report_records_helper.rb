module ReportRecordsHelper
	JSON_CHECK_VALUE		= :check_value
	JSON_CHECK_POINT		= :check_point
	JSON_VIDEO_NUM			= :video_num
	JSON_PHOTO_NUM			= :photo_num
	JSON_CAPTION_ENABLE		= :caption_enable


	JSON_BASE64_PHOTO				= :media_base64_encode_data
	JSON_UPLOAD_ORI_FILE_NAME		= :original_filename
	JSON_MEDIA_TYPE					= :media_type
	TMP_FILE_NAME					= "check_app_fileupload"
	JSON_PHOTO_PATH					= "photo_path"
	JSON_VIDEO_PATH					= "video_path"
	JSON_MEDIA_STORE_MODE			= "media_store_mode"

	DEFAULT_UPLOAD_ORI_FILE_NAME	= "defualt_upload_file_name"

	def new_report_record_json(report_record,check_point)
		json_add_data(JSON_VIDEO_NUM,1)
		json_add_data(JSON_PHOTO_NUM,get_photo_num(check_point))
		json_add_data(JSON_CAPTION_ENABLE,check_point.check_category.template.media_caption_enable)
		json_add_data(JSON_CHECK_POINT,check_point.as_json(CheckPoint::JSON_OPTS))
		json_add_data(JSON_CHECK_VALUE,check_point.check_category.template.check_value.as_json)
	end

	def report_record_id_json(report_record)
		json_add_data(:report_record_id,report_record.id)
	end
	def get_photo_num(check_point)
    	return check_point.check_category.template.zone_admin.check_point_photo_num
	end
	
	def deal_with_base64_data(params)
		media_infos = nil
		if not params["report_record"].nil?
			media_infos = params["report_record"]["media_infos_attributes"]
			return unless not media_infos.nil?
		end
		media_infos.each do |k,v|
			next unless v.is_a?(Hash)
			if v.has_key?(JSON_BASE64_PHOTO)
				tempfile = Tempfile.new(TMP_FILE_NAME)
				tempfile.binmode
				tempfile.write(Base64.decode64(v[JSON_BASE64_PHOTO]))
				tempfile.rewind()
				original_filename = v[JSON_UPLOAD_ORI_FILE_NAME]
				original_filename = DEFAULT_UPLOAD_ORI_FILE_NAME if original_filename.nil?

				mime_type = Mime::Type.lookup_by_extension(File.extname(original_filename)[1..-1]).to_s
				uploaded_file = ActionDispatch::Http::UploadedFile.new(
					:tempfile => tempfile, 
					:filename => original_filename, 
					:original_filename => original_filename) 
				if Rails.application.config.MediaPhotoTypeList.include?(v[JSON_MEDIA_TYPE])
					v[JSON_PHOTO_PATH] 			= uploaded_file
				elsif Rails.application.config.MediaVideoTypeList.include?(v[JSON_MEDIA_TYPE])
					v[JSON_VIDEO_PATH]			= uploaded_file
				else
					v[JSON_PHOTO_PATH]			= nil
					v[JSON_VIDEO_PATH]			= nil
				end
				v.delete(JSON_UPLOAD_ORI_FILE_NAME)
				v.delete(JSON_BASE64_PHOTO)
			end
		end
	end


	def _decode_base64
	end
end
