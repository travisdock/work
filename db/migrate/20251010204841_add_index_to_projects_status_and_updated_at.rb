class AddIndexToProjectsStatusAndUpdatedAt < ActiveRecord::Migration[8.1]
  def change
    add_index :projects, [ :status, :updated_at ]
  end
end
