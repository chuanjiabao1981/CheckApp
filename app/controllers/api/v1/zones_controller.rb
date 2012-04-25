class Api::V1::ZonesController < ApplicationController
  before_filter :api_request_verify ,only:[:zone_supervisor]
  def zone_supervisor
    @zone_admin    = current_api_user.zone_admin
    render json:{
                 "status"=>"ok",
                 "templates"=>@zone_admin.as_json(only:[],include:{templates:Template::JSON_OPTS})[:templates],
                 "zones"=>current_api_user.as_json(only:[],include:{zones:Zone::JSON_OPTS})[:zones]
                }
  end
end
