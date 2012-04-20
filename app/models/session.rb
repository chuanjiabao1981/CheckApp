class Session < ActiveRecord::Base
  belongs_to :login , polymorphic: true

  def site_admin?
    return true if self.login_type == 'SiteAdmin'
  end
  def zone_admin?
    return true if self.login_type  == 'ZoneAdmin'
  end
  def checker?
    return true if self.login_type == 'Checker'
  end
end
