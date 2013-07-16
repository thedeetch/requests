class CreateRequestComments < ActiveRecord::Migration
  def change
    create_table :request_comments do |t|
      t.integer :request_id
      t.string :user_id
      t.string :text

      t.timestamps
    end
  end
end
