# == Schema Information
#
# Table name: admins
#
#  id              :integer         not null, primary key
#  name            :string(255)
#  password_digest :string(255)
#  des             :string(255)
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#  contact         :string(255)
#  phone           :string(255)
#

class Admin < ActiveRecord::Base
  VALID_NAME_REGEX = /\A[a-z\d_]+\z/i
  attr_accessible :name,:des,:contact,:phone,:password,:password_confirmation
  has_secure_password
  validates :name,  presence: true, length:{ maximum:12 },  format:{with:VALID_NAME_REGEX} ,uniqueness: { case_sensitive: false }
  validates :des,   length:{maximum:250}
  validates :contact,length:{ maximum: 64 }
  validates :phone,  length:{ maximum: 64 }
  validates :password_confirmation,presence:true
end
