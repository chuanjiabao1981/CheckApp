class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
  include ReportsHelper
  include EquipmentsHelper
  include JsonResponseHelper
  include Api::V1::SessionsHelper

end
