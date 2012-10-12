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
    if (record.boolean_name         == ""   and \
        record.int_name             == ""   and \
        record.float_name           == ""   and \
        record.date_name            == ""   and \
        record.text_name            == ""   and \
        record.text_with_photo_name == ""      
        )  or \
       (record.boolean_name         == nil  and \
        record.int_name             == nil  and \
        record.float_name           == nil  and \
        record.date_name            == nil  and \
        record.text_name            == nil  and \
        record.text_with_photo_name == nil) 
      record.errors[:base] = "不能全为空"
    end
  end
end

class CheckValue < ActiveRecord::Base
  JSON_OPTS = {only:[:boolean_name,:int_name,:float_name,:date_name,:text_name]}
  attr_accessible :boolean_name,:int_name,:float_name,:date_name,:text_name,:text_with_photo_name
  belongs_to :template,inverse_of: :check_value
  validates :boolean_name,            length:{ maximum: 80} 
  validates :int_name,                length:{ maximum: 80}
  validates :float_name,              length:{ maximum: 80}
  validates :date_name,               length:{ maximum: 80}
  validates :text_name,               length:{ maximum: 80}
  validates :text_with_photo_name,    length:{ maximum: 80}
  validates_with NullNameValidator
  #这里只能用template不能用template_id
  #因为有可能template_id还不存在
  validates_presence_of :template

  def as_json
    super(only:[:boolean_name,:int_name,:float_name,:date_name,:text_name])
  end

  def has_boolean_name?
    return true if not real_empty?(self.boolean_name)
  end
  def has_int_name?
    return true if not real_empty?(self.int_name)
  end
  def has_float_name?
    return true if not real_empty?(self.float_name)
  end
  def has_date_name?
    return true if not real_empty?(self.date_name)
  end
  def has_text_name?
    return true if not real_empty?(self.text_name)
  end
  def has_text_with_photo_name?
    return true if not real_empty?(self.text_with_photo_name)
  end
private 
  def real_empty?(v)
    return true if v.nil? or v.strip.empty?
  end

end
