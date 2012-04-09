#encoding:utf-8
# == Schema Information
#
# Table name: check_values
#
#  id           :integer         not null, primary key
#  boolean_name :string(255)
#  int_name     :string(255)
#  float_name   :string(255)
#  date_name    :string(255)
#  template_id  :integer
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#  can_photo    :boolean         default(FALSE)
#  can_video    :boolean         default(FALSE)
#

class NullNameValidator < ActiveModel::Validator
  def validate(record)
    if (record.boolean_name == ""   and record.int_name == ""   and record.float_name == ""   and record.date_name == ""  )  or \
       (record.boolean_name == nil  and record.int_name == nil  and record.float_name == nil  and record.date_name == nil)
      record.errors[:base] = "当前模板至少要有一个检查项"
    end
  end
end

class CheckValue < ActiveRecord::Base
  belongs_to :template
  validates :boolean_name, length:{ maximum: 80} 
  validates :int_name,     length:{ maximum: 80}
  validates :float_name,   length:{ maximum: 80}
  validates :date_name,    length:{ maximum: 80}
  validates_with NullNameValidator
end
