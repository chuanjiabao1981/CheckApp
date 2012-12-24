#encoding:utf-8
module EquipmentsHelper

  def current_equipment_register?
    !current_equipment.nil?
  end

  def check_equipment_status
    if request.format == :mobile
      fee_left_day = current_equipment_left_time
      if not current_equipment_register?
        sign_out
        flash.now[:error]  = I18n.t 'errors.equipment.not_register'
        return render 'main/home',formats: [:mobile]
      elsif fee_left_day <= 0 
        sign_out
        flash.now[:error]  =  I18n.t 'errors.equipment.fee_expires'
        return render 'main/home',formats: [:mobile]
      elsif fee_left_day <= 60
        flash.now[:error]  = I18n.t 'warnnings.equipment.fee_left_day',:fee_left_day => fee_left_day
      end
    end
  end


  private 
    def current_equipment_left_time
      return 0 if not current_equipment_register?
      return (current_equipment.expire_date - Date.today).to_i
    end
    def current_equipment
      @current_equipment ||= Equipment.find_by_serial_num(current_equipment_serial_num)
    end

		def current_equipment_serial_num
    	splits = request.env['HTTP_USER_AGENT'].split(Rails.application.config.agent_splitor)
    	if splits.size == Rails.application.config.agent_split_num
      	return splits[Rails.application.config.agent_equipment_offset]
    	else
      	return request.env['HTTP_USER_AGENT']
    	end 
  	end
end
