module ZoneSupervisorsHelper
	def only_zone_supervisor
		return render json:json_base_errors(I18n.t('errors.session.type_wrong')) unless current_user.session.zone_supervisor?
	end
end
