class CreateSiteAdmins < ActiveRecord::Migration
  def change
    create_table :site_admins do |t|
      t.string :name
      t.string :des
      t.string :password_digest

      t.timestamps
    end
  end
end
