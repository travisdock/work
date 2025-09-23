class CreateProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :projects do |t|
      t.string :name, null: false
      t.text :description
      t.date :start_date
      t.date :due_date
      t.integer :status, default: 0
      t.integer :priority_number, default: 3
      t.text :priority_tags
      t.string :next_action

      t.timestamps
    end

    add_index :projects, :status
  end
end
