class Checker < ActiveRecord::Base
  VALID_NAME_REGEX = /\A[a-zA-Z\d_]+\z/i

  attr_accessible :name,:des,:password,:password_confirmation 

  before_save :create_remember_token

  has_secure_password

  belongs_to :organization,inverse_of: :checker,autosave:true

  has_one :session ,as: :login



  validates :name,  presence: true, length:{ maximum:36 },  format:{with:VALID_NAME_REGEX} ,uniqueness: { case_sensitive: false }
  validates :des,   length:{maximum:250}
  validates :password_confirmation,presence:true, :if => :validate_password?
  validates :organization,presence:true

private 
  def create_remember_token
    session = self.build_session()
    session.remember_token = SecureRandom.urlsafe_base64
  end
  def validate_password?
    password.present? || password_confirmation.present?
  end


 
end
