#encoding:utf-8
class UserSettingsController < ApplicationController
  def setting
  end
  def setting_update
  	if current_user.session.zone_admin?
  		if not current_user.update_attributes(params[:zone_admin])
  			return render 'setting'
  		end
  	elsif current_user.session.site_admin?
  		if not current_user.update_attributes(params[:site_admin])
  			return render 'setting'
  		end
  	elsif current_user.session.checker?
  		if not current_user.update_attributes(params[:checker])
  			return render 'setting'
  		end
    elsif current_user.session.zone_supervisor?
      if not current_user.update_attributes(params[:zone_supervisor])
        return render 'setting'
      end
  	end
  	flash[:success] = "密码更新成功！"
  	sign_in(current_user)
  	return redirect_to root_path
  end
end
