class CheckPointsController < ApplicationController
  before_filter :site_or_zone_admin_user,       only: [:new, :create,:edit,:update,:show,:index,:destroy]
  before_filter :correct_user_for_member,       only: [:edit,:update,:show,:destroy]
  before_filter :correct_user_for_collection,   only: [:new, :create,:index]

  def index
    @check_points = CheckPoint.find_all_by_check_category_id(params[:check_category_id])
  end
  def new
    @check_point  = CheckPoint.new
  end
  def create
    @check_point  = @category.check_points.build(params[:check_point])
    if @check_point.save
      return redirect_to check_category_check_points_path(@category)
    else
      render 'new'
    end
  end
  def edit
  end
  def update
    if @check_point.update_attributes(params[:check_point])
      return redirect_to check_category_check_points_path(@category)
    else
      render 'edit'
    end
  end
  def destroy
    @check_point.destroy
    return redirect_to check_category_check_points_path(@category)
  end

private

  def correct_user_for_member
    @check_point = CheckPoint.find_by_id(params[:id])
    return redirect_to root_path if not @check_point
    @category    = @check_point.check_category
    return redirect_to root_path if not @category
    @template    = @category.template
    return redirect_to root_path if not @template
    @zone_admin  = @template.zone_admin
    return redirect_to root_path unless @zone_admin == current_user or current_user.site_admin?
  end

  def correct_user_for_collection
    @category = CheckCategory.find_by_id(params[:check_category_id])
    return redirect_to root_path if not @category 
    @template = @category.template
    return redirect_to root_path if not @template
    @zone_admin = @template.zone_admin
    return redirect_to root_path unless @zone_admin == current_user or current_user.site_admin?
  end

end
