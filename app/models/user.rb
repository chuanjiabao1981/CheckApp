# encoding: utf-8
# == Schema Information
#
# Table name: users
#
#  id                                                                       :integer         not null, primary key
#  name                                                                     :string(255)
#  password_digest                                                          :string(255)
#  des                                                                      :string(255)
#  site_admin                                                               :boolean         default(FALSE)
#  zone_admin                                                               :boolean         default(FALSE)
#  zone_supervisor                                                          :boolean         default(FALSE)
#  org_worker                                                               :boolean         default(FALSE)
#  org_checker                                                              :boolean         default(FALSE)
#  created_at                                                               :datetime        not null
#  updated_at                                                               :datetime        not null
#  admin_id                                                                 :integer
#  #<ActiveRecord::ConnectionAdapters::TableDefinition:0x007fa8e3659ee0>_id :integer
#  remember_token                                                           :string(255)
#


class SupervisorValidator < ActiveModel::Validator
  def validate(record)
    if record.admin == nil
      record.errors[:base]="当前的supervisor没有zone管理员"
    elsif record.admin.zone_admin? == false
      record.errors[:base]="当前用户的管理者不是zone管理员"
    end
  end
end


class User < ActiveRecord::Base
  VALID_NAME_REGEX = /\A[a-zA-Z\d_]+\z/i
  attr_accessible :name,:des,:password,:password_confirmation
  has_secure_password
  before_save :create_remember_token

  validates :name,  presence: true, length:{ maximum:12 },  format:{with:VALID_NAME_REGEX} ,uniqueness: { case_sensitive: false }
  validates :des,   length:{maximum:250}
  validates :password_confirmation,presence:true,:unless=>"password==''"
  validates :admin_id,presence:true,:if=>:zone_supervisor?
  validates_with SupervisorValidator, :if=>:zone_supervisor?

  has_many    :supervisors,:class_name =>"User",foreign_key: "admin_id",:inverse_of=>:admin, :dependent => :destroy
  belongs_to  :admin,:class_name=>"User",:foreign_key=>"admin_id",:inverse_of=>:supervisors

  has_many    :templates,:dependent=>:destroy,foreign_key:"admin_id"


  private
    def create_remember_token
      self.remember_token = SecureRandom.urlsafe_base64
    end
end


