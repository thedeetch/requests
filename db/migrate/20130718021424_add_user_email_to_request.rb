class AddUserEmailToRequest < ActiveRecord::Migration
  def change
    add_column :requests, :user_email, :string
  end
end
