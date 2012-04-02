class AdminsController < ApplicationController
  def new
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
