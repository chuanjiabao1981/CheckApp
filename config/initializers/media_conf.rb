#encoding:utf-8
###本文件如有修改必须重启
###大写表示常量，小写表示变量
CheckApp::Application.configure  do
	###'local','remote'
	config.MediaStoreLocalMode			= 'local'
	config.MediaStoreRemoteMode			= 'remote'
	#检查点视频
	config.MediaTypeCheckPointVideo		= 'v'
	#检查点图片
	config.MediaTypeCheckPointPhoto		= 'p'
	#文字配图字段的图片
	config.MediaTypeTextWithPhoto		= 'tp'		
	config.MediaTypeTextWithVideo		= 'tv'

	config.media_store_mode 			= config.MediaStoreLocalMode

	config.MediaTypeList					= [config.MediaTypeCheckPointVideo,
		                                   config.MediaTypeCheckPointPhoto,
		                                   config.MediaTypeTextWithPhoto,
		                                   config.MediaTypeTextWithVideo
		                                  ]
    config.MediaPhotoTypeList			= [config.MediaTypeCheckPointPhoto,config.MediaTypeTextWithPhoto]
    config.MediaVideoTypeList			= [config.MediaTypeCheckPointVideo,config.MediaTypeTextWithVideo]


end