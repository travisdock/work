# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2025_10_10_204841) do
  create_table "projects", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.date "due_date"
    t.string "name", null: false
    t.string "next_action"
    t.integer "priority_number", default: 3
    t.text "priority_tags"
    t.date "start_date"
    t.integer "status", default: 0
    t.datetime "updated_at", null: false
    t.index ["status", "updated_at"], name: "index_projects_on_status_and_updated_at"
    t.index ["status"], name: "index_projects_on_status"
  end

  create_table "task_dependencies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "dependency_type", default: "finish_to_start"
    t.integer "predecessor_task_id", null: false
    t.integer "successor_task_id", null: false
    t.datetime "updated_at", null: false
    t.index ["predecessor_task_id", "successor_task_id"], name: "index_task_deps_on_pred_and_succ", unique: true
    t.index ["predecessor_task_id"], name: "index_task_dependencies_on_predecessor_task_id"
    t.index ["successor_task_id"], name: "index_task_dependencies_on_successor_task_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.date "due_date"
    t.string "effort_estimate"
    t.string "next_action"
    t.integer "parent_task_id"
    t.integer "position"
    t.integer "priority_number", default: 3
    t.text "priority_tags"
    t.integer "project_id", null: false
    t.date "start_date"
    t.integer "status", default: 0
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_task_id"], name: "index_tasks_on_parent_task_id"
    t.index ["project_id", "status"], name: "index_tasks_on_project_id_and_status"
    t.index ["project_id"], name: "index_tasks_on_project_id"
  end

  add_foreign_key "task_dependencies", "tasks", column: "predecessor_task_id"
  add_foreign_key "task_dependencies", "tasks", column: "successor_task_id"
  add_foreign_key "tasks", "projects"
  add_foreign_key "tasks", "tasks", column: "parent_task_id"
end
