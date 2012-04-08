class TemplatesController < ApplicationController
  before_filter :site_admin_user, only: [:new, :create,:edit,:update,:show,:index,:destroy]

  def index
    @templates = Template.all
  end
end
