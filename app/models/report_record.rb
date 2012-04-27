class ReportRecord < ActiveRecord::Base
  attr_accessible :check_point_id,:int_value,:float_value,:text_value,:boolean_value
  belongs_to :report
  belongs_to :check_point#,inverse_of: :report_records
  belongs_to :check_category


  validates :int_value, numericality: { :only_integer => true }
  validates :float_value,numericality:true
  validates :text_value,length:{maximum:1200}
  validates :check_point,presence:true
  validates :check_category,presence:true
  #validates :report,presence:true

  ##TODO::check_point和check_category 之间的对应关系
end
