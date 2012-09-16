#encoding:utf-8
module SessionsHelper
  def sign_in(user)
    cookies.permanent[:remember_token] = user.session.remember_token
    current_user = user
  end
  def sign_out
    current_user = nil
    cookies.delete(:remember_token)
  end
  def current_user=(user)
    @current_user = user
  end
  def current_user
    @current_user ||= user_from_remember_token2
  end
  def signed_in?
    !current_user.nil?
  end

  def site_admin_user
    redirect_to root_path unless (signed_in? and current_user.session.site_admin?)
  end

  def site_or_zone_admin_user
    redirect_to root_path unless (signed_in? and (current_user.session.site_admin? or current_user.session.zone_admin?))
  end

  def singed_in_user
    respond_to do |format| 
      format.html   {redirect_to root_path unless signed_in? }
      format.mobile {redirect_to root_path(format: :mobile) unless signed_in? }
    end
  end

  def current_equipment_serial_num
    splits = request.env['HTTP_USER_AGENT'].split(Rails.application.config.agent_splitor)
    if splits.size == Rails.application.config.agent_split_num
      return splits[Rails.application.config.agent_equipment_offset]
    else
      return request.env['HTTP_USER_AGENT']
    end 
  end
  def current_equipment
    @current_equipment ||= Equipment.find_by_serial_num(current_equipment_serial_num)
  end
  def current_equipment_register?
    !current_equipment.nil?
  end
  def current_checkapp_client_version
    splits = request.env['HTTP_USER_AGENT'].split(Rails.application.config.agent_splitor)
    if splits.size == Rails.application.config.agent_split_num
      return splits[Rails.application.config.agent_client_version_offset]
    else
      return request.env['HTTP_USER_AGENT']
    end
  end

  def current_equipment_left_time
    return 0 if not current_equipment_register?
    return (current_equipment.expire_date - Date.today).to_i
  end

  def checkapp_client_need_update
    if request.format =='mobile' and current_checkapp_client_version != Rails.application.config.check_client_version
      flash.now[:error] = Rails.application.config.agent_client_need_update_msg
    end
  end
  def validate_equipment
    if request.format == 'mobile'
      left_day = current_equipment_left_time
      if left_day <= 0
        sign_out
        return redirect_to root_path(format: :mobile)
      end
      if left_day <=60
        flash.now[:error] = "您设备的服务费用还有#{left_day}天到期，请及时续费，避免影响您的工作，谢谢！"
      end
    end
  end

  #说明：通用权限过滤
  #如果通过，输出
  #           1. @zone_admin
  def default_correct_user_for_collection(zone_admin)
    return false if not zone_admin
    return false unless zone_admin == current_user or current_user.session.site_admin?
    return true
  end

  private

    def user_from_remember_token2
      remember_token          = cookies[:remember_token]
      current_session         = Session.find_by_remember_token(remember_token)
      current_session.login   unless current_session.nil?
    end
    def user_from_remember_token
      remember_token = cookies[:remember_token]
      User.find_by_remember_token(remember_token) unless remember_token.nil?
    end

end
