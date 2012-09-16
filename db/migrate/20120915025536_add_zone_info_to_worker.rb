class AddZoneInfoToWorker < ActiveRecord::Migration
  def up
  	add_column :workers,:zone_admin_id,:integer
  	add_column :workers,:zone_id,:integer
  	worker_num = 0
  	Worker.all.each do |w|
  		worker_num 					= worker_num + 1
  		#创建relations
  		r 									= OrganizationWorkerRelation.new 
  		
  		w.organization_id   = w.id
  		r.organization_id 	= w.organization_id
  		r.worker_id					= w.id 
  		#记录zone_admin
  		w.zone_admin_id     = w.organization.zone.zone_admin_id
  		r.save 
  		w.save
  		print w.id,",",w.organization_id,"\n"
  	end
  	puts "CreateOrganizationWorkerRelation Size is " + OrganizationWorkerRelation.count.to_s
  	puts "Worker Size is " + Worker.count.to_s
  	remove_column :workers,:organization_id

  end
  def down
  	##添加organization_id 
  	add_column :workers,:organization_id,:integer
  	##恢复organizaion_id
  	OrganizationWorkerRelation.all.each do |r|
  		r.worker.organization_id = r.organization_id
  		r.worker.save
  		print r.worker.id,",",r.worker.organization_id,"\n"
  	end
  	OrganizationWorkerRelation.delete_all
  	remove_column :workers,:zone_id
  	remove_column :workers,:zone_admin_id
  end
end
