class Worker < ActiveRecord::Base
  VALID_NAME_REGEX = /\A[a-zA-Z\d_]+\z/i

  attr_accessible :name,:des,:password,:password_confirmation,:zone_id

  before_save :create_remember_token

  ##auto save导致factory_girl的:organization_with_a_checker_and_a_worker递归save
  ### 这个只是为了migaration使用
  ### 20120915025536_add_zone_info_to_worker.rb
  belongs_to :organization #inverse_of: :worker#,autosave:true

  has_many :organization_worker_relations,dependent: :destroy
  has_many :organizations,:through => :organization_worker_relations

  belongs_to :zone_admin
  belongs_to :zone
  
  has_one   :session ,as: :login

  has_many  :reports ,as: :committer,dependent: :destroy


  has_secure_password

  validates :name,  presence: true, length:{ maximum:128 },  format:{with:VALID_NAME_REGEX} ,uniqueness: { case_sensitive: false }
  validates :des,   length:{maximum:250}
#  validates :organization,presence:true


private 
  def create_remember_token
    session = self.build_session()
    session.remember_token = SecureRandom.urlsafe_base64
  end
end
