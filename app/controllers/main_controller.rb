class MainController < ApplicationController
  def home
  	logger.debug(request.format)
  end
end
