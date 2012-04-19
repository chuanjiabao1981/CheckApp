class CreateCheckPoints < ActiveRecord::Migration
  def change
    create_table :check_points do |t|
      t.text :content
      t.references :check_category
      t.boolean :can_photo,default:false
      t.boolean :can_video,default:false

      t.timestamps
    end
  end
end
