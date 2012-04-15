class Organization < ActiveRecord::Base
  attr_accessible :name,:phone,:contact,:address
  belongs_to :zone
end
