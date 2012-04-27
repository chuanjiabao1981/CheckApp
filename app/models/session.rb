class Session < ActiveRecord::Base
  
  belongs_to :login , polymorphic: true


  def as_json(options={})
    a          = {}
    a["token"] = self.remember_token
    a
    #super(:only=>[:remember_token])
  end
  def site_admin?
    return true if self.login_type == 'SiteAdmin'
  end
  def zone_admin?
    return true if self.login_type  == 'ZoneAdmin'
  end
  def checker?
    return true if self.login_type == 'Checker'
  end
  def worker?
    return true if self.login_type  == 'Worker'
  end
  def zone_supervisor?
    return true if self.login_type == 'ZoneSupervisor'
  end
end
