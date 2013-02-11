module ReportRecordsHelper
	JSON_CHECK_VALUE		= :check_value
	JSON_CHECK_POINT		= :check_point
	JSON_VIDEO_NUM			= :video_num
	JSON_PHOTO_NUM			= :photo_num
	JSON_CAPTION_ENABLE		= :caption_enable


	JSON_BASE64_PHOTO		= :photo_base64_encode_data
	JSON_PHOTO_ORI_NAME		= :original_filename
	JSON_MEDIA_TYPE			= :media_type
	TMP_FILE_NAME			= "check_app_fileupload"
	JSON_PHOTO_PATH			= "photo_path"
	JSON_MEDIA_STORE_MODE	= "media_store_mode"

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
	##TODO
	## 如果格式错误怎么办 例如 没有media_type or something
	## local 模式需要处理
	## 确认大小在手机上看怎么样
	## 反复create 会怎样
	## lining 创建后，不能看到创建按钮 ，否则会出重复数据？？ 
	def deal_with_base64_photo_data(params)
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
				original_filename = v[JSON_PHOTO_ORI_NAME]
				mime_type = Mime::Type.lookup_by_extension(File.extname(original_filename)[1..-1]).to_s
				uploaded_file = ActionDispatch::Http::UploadedFile.new(
					:tempfile => tempfile, 
					:filename => v[JSON_PHOTO_ORI_NAME], 
					:original_filename => v[JSON_PHOTO_ORI_NAME]) 
				v[JSON_PHOTO_PATH] 			= uploaded_file
				v.delete(JSON_PHOTO_ORI_NAME)
				v.delete(JSON_BASE64_PHOTO)
			end
		end
	end


	def _decode_base64
	end
end
