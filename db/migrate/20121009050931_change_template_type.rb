class ChangeTemplateType < ActiveRecord::Migration
  def up
  	Template.all.each do |t|
  		print t.name,"\t",t.for_supervisor,"\t",t.for_worker,"\n"
  		t.for_worker = true
  		t.for_supervisor = true
  		t.save
  	end
  	print "==========================\n"
  	Template.all.each do |t|
  		print t.name,"\t",t.for_supervisor,"\t",t.for_worker,"\n"
  	end
  end

  def down
  end
end
