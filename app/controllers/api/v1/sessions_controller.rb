#encoding:utf-8
class Api::V1::SessionsController < ApplicationController
  def zone_supervisor_login
    logger.debug(params)
    zone_supervisor = ZoneSupervisor.find_by_name(params[:session][:name])
    logger.debug(params[:session][:name])
    logger.debug(params[:session][:password])
    if zone_supervisor and zone_supervisor.authenticate(params[:session][:password])
      render json:{status:"ok",login:zone_supervisor.session}
      #render json:zone_supervisor.to_json
    else
      render json:{status:"fail",reason:{用户名或密码:["错误"]}}
    end
  end
end
