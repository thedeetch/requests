class Team < ActiveRecord::Base
  attr_accessible :name, :directory_id

  has_many :request_teams
  has_many :requests, through: :request_teams
  has_many :systems
end
