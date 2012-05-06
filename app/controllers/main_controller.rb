class MainController < ApplicationController
  def home
  	if signed_in? and current_user.session.worker?
  		return redirect_to worker_organization_reports_path(current_user.organization,format: :mobile)
  	end
  end
end
