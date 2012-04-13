class TemplatesController < ApplicationController
  before_filter :site_or_zone_admin_user,       only: [:new, :create,:edit,:update,:show,:index,:destroy]
  before_filter :correct_user_for_member,       only: [:edit,:update,:show,:destroy]
  before_filter :correct_user_for_collection,   only: [:new, :create,:index]

  def index
    @templates = Template.find_all_by_admin_id(@zone_admin.id)
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
    @template     = @zone_admin.templates.build(params[:template])
    if  @template.save
      redirect_to zone_admin_templates_path(@zone_admin)
    else
      render 'new'
    end
  end
  def edit
    @template = Template.find_by_id(params[:id])
    if not @template
      redirect_to root_path
    end
  end
  def update
    if @template.update_attributes(params[:template])
      redirect_to template_path(@template)
    else
      render 'edit'
    end
  end
  def destroy
    #k = Template.find(params[:id])
    @zone_admin = @template.zone_admin
    @template.destroy
    #k.destroy
    redirect_to zone_admin_templates_path(@zone_admin)
  end

  private
  def correct_user_for_member
    @template = current_user.templates.find_by_id(params[:id])
    redirect_to root_path if @template.nil? and not current_user.site_admin?
  end
  def correct_user_for_collection
    if current_user.zone_admin?
      @zone_admin = current_user
    elsif current_user.site_admin?
      @zone_admin = User.find_by_id(params[:zone_admin_id])
    end
    if @zone_admin.id.to_s != params[:zone_admin_id] 
      redirect_to root_path
    end
  end
end
