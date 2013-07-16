class RenameRequestType < ActiveRecord::Migration
  def change
  	rename_column :requests, :type, :context
  end
end
