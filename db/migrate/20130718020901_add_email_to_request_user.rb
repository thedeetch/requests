class AddEmailToRequestUser < ActiveRecord::Migration
  def change
    add_column :request_users, :email, :string
  end
end
