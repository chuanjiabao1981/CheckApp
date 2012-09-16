class WorkersController < ApplicationController
	before_filter :site_or_zone_admin_user
	before_filter :correct_user_for_collection,   only: [:new, :create,:index]
	before_filter :correct_user_for_member,       only: [:edit,:update,:destroy]


	def index
		@workers = @zone_admin.workers
	end
  def new
  	@worker   = @zone_admin.workers.build()
  end
  def create
  	@worker  	= @zone_admin.workers.build(params[:worker])
  	if @worker.save
  		redirect_to zone_admin_workers_path(@zone_admin)
  	else
  		render 'new'
  	end
  end

  def edit
  end
  def update
    if @worker.update_attributes(params[:worker])
      return redirect_to zone_admin_workers_path(@zone_admin)
    else
      render 'edit'
    end
  end
  def destroy
    @worker.destroy
    return redirect_to zone_admin_workers_path(@zone_admin)
  end

private
  def correct_user_for_member
    @worker               = Worker.find_by_id(params[:id])
    return redirect_to root_path if not @worker
    @zone_admin             = @worker.zone_admin
    return redirect_to root_path unless default_correct_user_for_collection(@zone_admin)
  end
	def correct_user_for_collection
		@zone_admin             = ZoneAdmin.find_by_id(params[:zone_admin_id])
		return redirect_to root_path unless default_correct_user_for_collection(@zone_admin)
	end
end
