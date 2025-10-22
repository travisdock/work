class AddUserReferencesToProjectsAndTasks < ActiveRecord::Migration[8.1]
  def change
    add_reference :projects, :user, null: false, foreign_key: true
    add_reference :tasks, :user, null: false, foreign_key: true

    add_index :projects, [ :user_id, :status ]
    add_index :tasks, [ :user_id, :status ]
  end
end
