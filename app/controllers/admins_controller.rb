class AdminsController < ApplicationController
  def new
    @admin = Admin.new
  end
  def create
    @admin = Admin.new(params[:admin])
    if @admin.save
      redirect_to admin_path(@admin)
    else
      render 'new'
    end
  end
  def index
  end
  def show
    @admin = Admin.find_by_id(params[:id])
    if not @admin then
      redirect_to admins_path
    end
  end
end
