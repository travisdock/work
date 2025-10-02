class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.string :title, null: false
      t.text :description
      t.references :project, null: false, foreign_key: true
      t.references :parent_task, foreign_key: { to_table: :tasks }
      t.date :start_date
      t.date :due_date
      t.integer :status, default: 0
      t.integer :priority_number, default: 3
      t.text :priority_tags
      t.string :effort_estimate
      t.string :next_action
      t.integer :position

      t.timestamps
    end

    add_index :tasks, [ :project_id, :status ]
  end
end
