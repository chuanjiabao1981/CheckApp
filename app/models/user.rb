class User < ActiveRecord::Base
  VALID_NAME_REGEX = /\A[a-zA-Z\d_]+\z/i
  attr_accessible :name,:des,:password,:password_confirmation
  has_secure_password
  validates :name,  presence: true, length:{ maximum:12 },  format:{with:VALID_NAME_REGEX} ,uniqueness: { case_sensitive: false }
  validates :des,   length:{maximum:250}
  validates :password_confirmation,presence:true

  has_many    :supervisors,:class_name =>"User"
  belongs_to  :admin,:class_name=>"User"
end
