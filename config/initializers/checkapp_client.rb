#encoding:utf-8
###本文件如有修改必须重启
###本文件如有修改必须重启
CheckApp::Application.configure  do
	#客户端版本号,每次升级客户端必须修改
	config.check_client_version 			= "0.14"
	#agent的分隔符，格式为：	//imeistring:imsistring:version:andriod[24]
	config.agent_splitor					= '@' 
	config.agent_split_num					= 4
	#从agent中获取设备id
	config.agent_equipment_offset			= 0
	#从agent中获取客户端版本号
	config.agent_client_version_offset		= 2

	config.agent_client_need_update_msg		= "请尽快升级客户端程序，以免影响系统的正常使用！[设置]->[系统升级]"
end
