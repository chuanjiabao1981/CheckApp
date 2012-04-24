#encoding:utf-8
class Api::V1::SessionsController < ApplicationController
  def zone_supervisor_login
    zone_supervisor = ZoneSupervisor.find_by_name(params[:session][:name])
    if zone_supervisor and zone_supervisor.authenticate(params[:session][:password])
      render json:{status:"ok",login:zone_supervisor.session}
    else
      render json:{status:"fail",reason:{用户名或密码:["错误"]}}
    end
  end
  def worker_login
    worker  = Worker.find_by_name(params[:session][:name])
    if worker and worker.authenticate(params[:session][:password])
      render json:{status:"ok",login:worker.session}
    else
      render json:{status:"fail",reason:{用户名或密码:["错误"]}}
    end
  end
end
