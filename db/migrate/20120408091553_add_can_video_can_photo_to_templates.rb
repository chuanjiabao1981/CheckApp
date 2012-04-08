class AddCanVideoCanPhotoToTemplates < ActiveRecord::Migration
  def change
    add_column :templates,:can_video,:boolean,default:false
    add_column :templates,:can_photo,:boolean,default:false
  end
end
