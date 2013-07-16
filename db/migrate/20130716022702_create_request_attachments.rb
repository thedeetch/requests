class CreateRequestAttachments < ActiveRecord::Migration
  def change
    create_table :request_attachments do |t|
      t.integer :request_id

      t.timestamps
    end
  end
end
