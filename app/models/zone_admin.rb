class ZoneAdmin < ActiveRecord::Base
  VALID_NAME_REGEX = /\A[a-zA-Z\d_]+\z/i

  attr_accessible :name,:des,:password,:password_confirmation,:template_max_num,:template_max_video_num,:template_max_photo_num,:check_point_photo_num,:check_point_video_num 

  before_save :create_remember_token

  has_secure_password

  has_one :session ,as: :login

  has_many :templates,dependent: :destroy
  has_many :zone_supervisors,dependent: :destroy
  has_many :zones,dependent: :destroy

  belongs_to :site_admin


  validates :name,  presence: true, length:{ maximum:36 },  format:{with:VALID_NAME_REGEX} ,uniqueness: { case_sensitive: false }
  validates :des,   length:{maximum:250}
  #validates :password_confirmation,presence:true,:unless=>"password==''"
  validates :template_max_num, :numericality => { only_integer:true ,greater_than_or_equal_to:0}
  validates :template_max_video_num, :numericality => { only_integer:true ,greater_than_or_equal_to:0}
  validates :template_max_photo_num, :numericality => { only_integer:true ,greater_than_or_equal_to:0}


  def get_all_templates_num
    return self.templates.size
  end


private 
  def create_remember_token
    session = self.build_session()
    session.remember_token = SecureRandom.urlsafe_base64
  end

end
