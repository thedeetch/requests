class Request < ActiveRecord::Base
  attr_accessible :behalf_of_user_id, :category, :description, :priority, :size, :status, :target_date, :title, :context, :user_id, :system_id, :comments_attributes

  has_many :request_comments, :dependent => :destroy
  has_many :request_attachments, :dependent => :destroy
  has_many :request_users, :dependent => :destroy
  has_many :request_teams, :dependent => :destroy
  has_many :teams, through: :request_teams
  belongs_to :system
end
