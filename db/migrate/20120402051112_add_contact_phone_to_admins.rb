class AddContactPhoneToAdmins < ActiveRecord::Migration
  def change
    add_column :admins, :contact, :string

    add_column :admins, :phone, :string

  end
end
