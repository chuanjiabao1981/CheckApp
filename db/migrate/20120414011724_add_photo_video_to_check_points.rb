class AddPhotoVideoToCheckPoints < ActiveRecord::Migration
  def change
    add_column :check_points,:can_photo,:boolean,default:false
    add_column :check_points,:can_video,:boolean,default:false
  end
end
