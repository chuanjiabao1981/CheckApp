class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
  include Api::V1::SessionsHelper

  before_filter :set_locale

	def set_locale
  	I18n.locale = 'cn'
	end
end
