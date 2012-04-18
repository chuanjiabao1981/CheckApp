class CreateZoneAdmins < ActiveRecord::Migration
  def change
    create_table :zone_admins do |t|
      t.string :name
      t.string :des
      t.string :password_digest
      t.integer    :template_max_num,default:2
      t.integer    :template_max_photo_num,default:5
      t.integer    :template_max_video_num,default:1
      t.references :site_admin

      t.timestamps
    end
  end
end
