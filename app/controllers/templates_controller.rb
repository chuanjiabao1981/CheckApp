class TemplatesController < ApplicationController
  before_filter :site_admin_user, only: [:new, :create,:edit,:update,:show,:index,:destroy]

  def index
    @templates = Template.all
  end
  def show
    @template     = Template.find_by_id(params[:id])
    if not @template 
      redirect_to root_path
    end
  end
  def new
    @template      = Template.new
    @template.build_check_value
  end
  def create
    @template     = current_user.templates.build(params[:template])
    if  @template.save
      redirect_to templates_path
    else
      render 'new'
    end
  end
end
