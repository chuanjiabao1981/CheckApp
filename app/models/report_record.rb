class ReportRecord < ActiveRecord::Base
  belongs_to :report
  belongs_to :check_point
end
