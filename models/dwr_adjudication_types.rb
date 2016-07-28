class DwrAdjudicationTypes < ActiveRecord::Base

  has_and_belongs_to_many :dwr_water_rights

end