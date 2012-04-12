class CheckCategoriesController < ApplicationController
  before_filter :site_or_zone_admin_user,       only: [:new, :create,:edit,:update,:show,:index,:destroy]
  before_filter :correct_user_for_member,       only: [:edit,:update,:show,:destroy]
  before_filter :correct_user_for_collection,   only: [:new, :create,:index]

  def index
    @categories = CheckCategory.find_all_by_template_id(params[:template_id])
  end

private

  def correct_user_for_member
  end

  def correct_user_for_collection
    @template = Template.find_by_id(params[:template_id])
    return redirect_to root_path if not @template or not @template.zone_admin
    @zone_admin = @template.zone_admin
    return redirect_to root_path unless @zone_admin == current_user or current_user.site_admin? 
  end

end
