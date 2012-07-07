class EquipmentsController < ApplicationController
	before_filter :correct_visit_user	,						only:[:index]
	before_filter :site_admin_user 		, 					only:[:new,:create,:edit,:update,:destroy]
	before_filter :get_zone_admin	 		,						only:[:new,:create]
  before_filter :refuse_register_equipment,     only:[:register_equipment,:create_equipment]
	
	def index
		@equipments = @zone_admin.equipments
	end
  def new
  	@equipment = @zone_admin.equipments.build()
  end
  def create
  	@equipment = @zone_admin.equipments.build(params[:equipment])
  	if @equipment.save
  		return redirect_to zone_admin_equipments_path(@zone_amdin)
  	else
  		render 'new'
  	end
  end
  def edit
    @equipment = Equipment.find(params[:id])
    return redirect_to root_path if @equipment.nil?
  end
  def update
    @equipment =Equipment.find(params[:id])
    return redirect_to root_path if @equipment.nil?
    if @equipment.update_attributes(params[:equipment])
      return redirect_to zone_admin_equipments_path(@equipment.zone_admin)
    else
      render 'edit'
    end
  end
  def destroy
    @equipment =Equipment.find(params[:id])
    @equipment.destroy
    return redirect_to zone_admin_equipments_path(@equipment.zone_admin)
  end
  def register_equipment
    @equipment         = Equipment.new
    @all_zone_admins   = ZoneAdmin.all
  end
  def create_equipment
    return redirect_to root_path(format: :mobile) if params[:confirm][:password] != 'mckmgw'
    @equipment = Equipment.new(params[:equipment])
    if @equipment.save
      redirect_to root_path(format: :mobile)
    else
      @all_zone_admins  = ZoneAdmin.all
      render 'register_equipment',formats: [:mobile]
    end
  end
  private 
    def refuse_register_equipment
      return redirect_to root_path(format: :mobile) if current_equipment_register?
    end
  	def get_zone_admin
  		@zone_admin = ZoneAdmin.find_by_id(params[:zone_admin_id])
  		return redirect_to root_path if @zone_admin.nil?
  	end
  	def correct_visit_user
  		@zone_admin = ZoneAdmin.find_by_id(params[:zone_admin_id])
      return redirect_to root_path if @zone_admin.nil?
  		return redirect_to root_path unless @zone_admin == current_user or current_user.session.site_admin?
  	end
end
