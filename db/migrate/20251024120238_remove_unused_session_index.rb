class RemoveUnusedSessionIndex < ActiveRecord::Migration[8.1]
  def change
    if index_exists?(:sessions, [ :user_id, :last_activity_at ])
      remove_index :sessions, [ :user_id, :last_activity_at ]
    end
  end
end
