class RequestTeam < ActiveRecord::Base
  attr_accessible :request_id, :team_id

  belongs_to :request
  belongs_to :team
end
