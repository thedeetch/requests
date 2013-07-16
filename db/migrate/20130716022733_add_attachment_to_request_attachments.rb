class AddAttachmentToRequestAttachments < ActiveRecord::Migration
  def change
  	add_column :request_attachments, :attachment, :string
  end
end
