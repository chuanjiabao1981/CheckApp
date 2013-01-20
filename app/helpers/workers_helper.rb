module WorkersHelper
	def only_worker
		return render json:json_base_errors(I18n.t('errors.session.type_wrong')) unless current_user.session.worker?
	end
end
