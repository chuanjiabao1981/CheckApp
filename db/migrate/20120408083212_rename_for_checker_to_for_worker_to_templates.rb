class RenameForCheckerToForWorkerToTemplates < ActiveRecord::Migration
  def up
    change_table :templates do |t|
      t.rename :for_checker,:for_worker
    end

  end

  def down
    change_table :templates do |t|
      t.rename :for_worker,:for_checker
    end

  end
end
