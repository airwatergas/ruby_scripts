class DwrWaterRights < ActiveRecord::Base

  has_and_belongs_to_many :dwr_adjudication_types
  has_and_belongs_to_many :dwr_decreed_uses

end