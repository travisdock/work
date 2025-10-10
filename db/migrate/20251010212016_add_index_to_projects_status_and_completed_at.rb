class AddIndexToProjectsStatusAndCompletedAt < ActiveRecord::Migration[8.1]
  def change
    add_index :projects, [ :status, :completed_at ],
              name: "index_projects_on_status_and_completed_at"
  end
end
