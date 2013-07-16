class AddSystemIdToRequest < ActiveRecord::Migration
  def change
    add_column :requests, :request_id, :integer
  end
end
