class AddMissingFieldsToRequestUser < ActiveRecord::Migration
  def change
  	add_column :request_users, :role, :string
  	add_column :request_users, :begin, :datetime
  	add_column :request_users, :end, :datetime
  	add_column :request_users, :allocation, :integer
  end
end
