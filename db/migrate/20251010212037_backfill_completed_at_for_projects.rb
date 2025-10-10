class BackfillCompletedAtForProjects < ActiveRecord::Migration[8.1]
  def up
    # Backfill existing completed/cancelled projects with their updated_at timestamp
    # This is our best approximation of when they were actually completed
    Project.where(status: [ :completed, :cancelled ])
           .where(completed_at: nil)
           .find_each do |project|
      project.update_column(:completed_at, project.updated_at)
    end
  end

  def down
    # Optionally clear backfilled data if rolling back
    # Note: This loses the backfilled timestamps
  end
end
