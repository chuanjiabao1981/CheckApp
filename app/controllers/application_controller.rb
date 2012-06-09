class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
  include ReportsHelper
  include Api::V1::SessionsHelper

end
