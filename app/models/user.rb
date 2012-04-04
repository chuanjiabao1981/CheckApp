# encoding: utf-8

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
  validates :name,  presence: true, length:{ maximum:12 },  format:{with:VALID_NAME_REGEX} ,uniqueness: { case_sensitive: false }
  validates :des,   length:{maximum:250}
  validates :password_confirmation,presence:true

  validates :admin_id,presence:true,:if=>:supervisor?
  has_many    :supervisors,:class_name =>"User",foreign_key: "admin_id",:inverse_of=>:admin, :dependent => :destroy
  belongs_to  :admin,:class_name=>"User",:foreign_key=>"admin_id",:inverse_of=>:supervisors


  validates_with SupervisorValidator, :if=>:supervisor?
end


