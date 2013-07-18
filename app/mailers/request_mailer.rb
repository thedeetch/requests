class RequestMailer < ActionMailer::Base
  default from: "itrequests@thedeetch.com"

  def new_request(request)
  	@request = request

  	mail(to: @request.user_email, subject: 'New Request Submitted')
  end

  def update_request(request)
  	@request = request

  	mail(to: @request.user_email, subject: 'Request Updated')
  end
end
