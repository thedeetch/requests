class System < ActiveRecord::Base
  attr_accessible :name, :team_id

  belongs_to :team
  has_many :requests
end
