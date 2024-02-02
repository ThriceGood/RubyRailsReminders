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

ActiveRecord::Schema[7.1].define(version: 2024_02_02_080347) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "ticket_statuses", force: :cascade do |t|
    t.string "name"
    t.index ["name"], name: "index_ticket_statuses_on_name", unique: true
  end

  create_table "tickets", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.integer "assigned_user_id"
    t.date "due_date"
    t.integer "ticket_status_id"
    t.integer "progress"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assigned_user_id"], name: "index_tickets_on_assigned_user_id"
    t.index ["ticket_status_id"], name: "index_tickets_on_ticket_status_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.boolean "send_due_date_reminder", default: false, comment: "Flag to send ticket due date reminders"
    t.integer "due_date_reminder_day_offset", comment: "Days before a ticket's due date to send reminders"
    t.string "due_date_reminder_time", comment: "Time of day user wishes to receive reminder email"
    t.integer "due_date_reminder_interval", comment: "Daily interval to receive reminders before due date"
    t.string "time_zone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "configured_reminder_types", default: ["email"], array: true
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "tickets", "ticket_statuses"
  add_foreign_key "tickets", "users", column: "assigned_user_id"
end
