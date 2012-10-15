class ZoneAdmin < ActiveRecord::Base
  VALID_NAME_REGEX = /\A[a-zA-Z\d_]+\z/i

  attr_accessible :name,:des,:password,:password_confirmation,\
                  :template_max_num,:template_max_video_num,\
                  :template_max_photo_num,:check_point_photo_num,\
                  :check_point_video_num ,:max_org_num,:max_zone_supervisor_num,\
                  :max_backup_month,\
                  :can_text_with_photo,:can_media_caption,\
                  :max_supervisor_report_num,\
                  :max_worker_report_num

  before_save :create_remember_token

  has_secure_password

  has_one :session ,as: :login

  has_many :templates,dependent: :destroy
  has_many :zone_supervisors,dependent: :destroy
  has_many :zones,dependent: :destroy
  has_many :equipments,dependent: :destroy
  has_many :locations,dependent: :destroy
  has_many :workers,dependent: :destroy

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
  def get_all_orgs_num
    s = 0 
    self.zones.each do |z|
      s = s + z.organizations.size
    end
    return s
  end
  def get_all_zone_supervisors_num
    return self.zone_supervisors.size
  end
  def get_all_supervisor_report_num
    return get_all_report_num('ZoneSupervisor')
  end
  def get_all_worker_report_num
    return get_all_report_num('Worker')
  end



private 
  def get_all_report_num(reportType)
    s = 0
    self.templates.each do |t|
      k = t.reports.where("committer_type=?",reportType.to_s).size
      s = s + k
      Rails.logger.debug("Template["+t.name+"] has "+k.to_s + " "+reportType + " reports")
    end
    Rails.logger.debug("zone admin has "+s.to_s + " "+reportType + " reports")
    return s
  end
  def create_remember_token
    session = self.build_session()
    session.remember_token = SecureRandom.urlsafe_base64
  end

end
