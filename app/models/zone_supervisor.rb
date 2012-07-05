#encoding:utf-8
class ZoneSupervisorValidator < ActiveModel::Validator
  def validate(record)
    if (record.zone_admin.get_all_zone_supervisors_num + 1) > record.zone_admin.max_zone_supervisor_num
      record.errors[:base] = "您的账户仅能创建#{record.zone_admin.max_zone_supervisor_num}个督察员。"
      return 
    end
  end
end

class ZoneSupervisor < ActiveRecord::Base
  VALID_NAME_REGEX = /\A[a-zA-Z\d_]+\z/i

  JSON_OPTS = {only:[],include:{zones:Zone::JSON_OPTS}}

  attr_accessible :name,:des,:password,:password_confirmation 

  before_save :create_remember_token

  has_secure_password

  has_one :session ,as: :login

  has_many :zone_supervisor_relations,dependent: :destroy
  has_many :zones,through: :zone_supervisor_relations
  has_many :reports,as: :committer
  
  belongs_to :zone_admin

  validates :name,  presence: true, length:{ maximum:36 },  format:{with:VALID_NAME_REGEX} ,uniqueness: { case_sensitive: false }
  validates :des,   length:{maximum:250}
#  validates :password_confirmation,presence:true,:unless=>"password==''"
  validates_with ZoneSupervisorValidator

private 
  def create_remember_token
    session = self.build_session()
    session.remember_token = SecureRandom.urlsafe_base64
  end

end
