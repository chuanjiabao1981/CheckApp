class RemovePhotoVideoToCheckFromTemplatesAndCheckValues < ActiveRecord::Migration
  def up
    remove_column :templates,:can_photo
    remove_column :templates,:can_video
    remove_column :check_values,:can_photo
    remove_column :check_values,:can_video
  end

  def down
    add_column :templates,:can_photo,:boolean,default:false
    add_column :templates,:can_video,:boolean,default:false
    add_column :check_values,:can_photo,:boolean,default:false
    add_column :check_values,:can_video,:boolean,default:false
  end
end
