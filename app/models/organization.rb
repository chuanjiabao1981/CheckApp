class Organization < ActiveRecord::Base
  attr_accessible :name,:phone,:contact,:address

  belongs_to :zone
  
  has_one :checker,dependent: :destroy
  has_one :worker ,dependent: :destroy

  has_many :reports,dependent: :destroy

  validates :name       ,presence:true,length:{maximum:250}
  validates :phone      ,presence:true,length:{maximum:250}
  validates :contact    ,presence:true,length:{maximum:250}
  validates :address    ,presence:true,length:{maximum:250}

  def create_user_report(user,report_name,reportemplate,organization)
    worker_report = false
    supervisor_report = false
    if user.session.is_worker?
      worker_report = true
    elsif current_user.session.is_supervisor?
      supervisor_report = true
    end
  end
end
