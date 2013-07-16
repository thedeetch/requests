class RequestComment < ActiveRecord::Base
  attr_accessible :text, :request_id, :user_id

  belongs_to :request
end
