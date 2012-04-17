class Organization < ActiveRecord::Base
  attr_accessible :name,:phone,:contact,:address

  belongs_to :zone
  
  has_one :checker,dependent: :destroy
  has_one :worker ,dependent: :destroy,inverse_of: :organization,autosave:true

  has_many :reports,dependent: :destroy

  validates :name       ,presence:true,length:{maximum:250}
  validates :phone      ,presence:true,length:{maximum:250}
  validates :contact    ,presence:true,length:{maximum:250}
  validates :address    ,presence:true,length:{maximum:250}

end
