#encoding:utf-8
class Api::V1::SessionsController < ApplicationController
  def zone_supervisor_login
    zone_supervisor = ZoneSupervisor.find_by_name(params[:session][:name])
    logger.debug(params[:session][:name])
    logger.debug(params[:session][:password])
    if zone_supervisor and zone_supervisor.authenticate(params[:session][:password])
      #render json:{status:"ok",token:zone_supervisor.session.remember_token}
      render json:zone_supervisor.to_json
    else
      render json:{status:"fail",reason:{用户名或密码:["错误"]}}
    end
  end
end
