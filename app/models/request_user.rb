class RequestUser < ActiveRecord::Base
  attr_accessible :request_id, :user_id, :role, :begin, :end, :allocation

  belongs_to :request
end
