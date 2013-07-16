class RequestAttachment < ActiveRecord::Base
  attr_accessible :request_id, :attachment

  belongs_to :request

  mount_uploader :attachment, AttachmentUploader
end
