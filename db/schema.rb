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

ActiveRecord::Schema[8.1].define(version: 2026_04_02_233100) do
  create_table "activity_logs", force: :cascade do |t|
    t.string "action", null: false
    t.datetime "created_at", null: false
    t.string "field_changed"
    t.string "new_value"
    t.string "old_value"
    t.integer "ticket_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["action"], name: "index_activity_logs_on_action"
    t.index ["ticket_id"], name: "index_activity_logs_on_ticket_id"
    t.index ["user_id"], name: "index_activity_logs_on_user_id"
  end

  create_table "api_tokens", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "last_used_at"
    t.string "name", null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["active"], name: "index_api_tokens_on_active"
    t.index ["token"], name: "index_api_tokens_on_token", unique: true
    t.index ["user_id"], name: "index_api_tokens_on_user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.boolean "agent_authored", default: false, null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.integer "ticket_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["ticket_id"], name: "index_comments_on_ticket_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "labels", force: :cascade do |t|
    t.string "color", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "project_id", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id", "name"], name: "index_labels_on_project_id_and_name", unique: true
    t.index ["project_id"], name: "index_labels_on_project_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "actor_id", null: false
    t.datetime "created_at", null: false
    t.string "message", null: false
    t.string "notification_type"
    t.boolean "read", default: false, null: false
    t.integer "recipient_id", null: false
    t.integer "ticket_id"
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_notifications_on_actor_id"
    t.index ["created_at"], name: "index_notifications_on_created_at"
    t.index ["read"], name: "index_notifications_on_read"
    t.index ["recipient_id"], name: "index_notifications_on_recipient_id"
    t.index ["ticket_id"], name: "index_notifications_on_ticket_id"
  end

  create_table "pr_links", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "status", default: 0, null: false
    t.integer "ticket_id", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.string "url", null: false
    t.integer "user_id", null: false
    t.index ["status"], name: "index_pr_links_on_status"
    t.index ["ticket_id"], name: "index_pr_links_on_ticket_id"
    t.index ["user_id"], name: "index_pr_links_on_user_id"
  end

  create_table "project_memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "project_id", null: false
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["project_id", "user_id"], name: "index_project_memberships_on_project_id_and_user_id", unique: true
    t.index ["project_id"], name: "index_project_memberships_on_project_id"
    t.index ["role"], name: "index_project_memberships_on_role"
    t.index ["user_id"], name: "index_project_memberships_on_user_id"
  end

  create_table "projects", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "key", null: false
    t.string "name", null: false
    t.integer "ticket_sequence", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_projects_on_key", unique: true
  end

  create_table "ticket_labels", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "label_id", null: false
    t.integer "ticket_id", null: false
    t.datetime "updated_at", null: false
    t.index ["label_id"], name: "index_ticket_labels_on_label_id"
    t.index ["ticket_id", "label_id"], name: "index_ticket_labels_on_ticket_id_and_label_id", unique: true
    t.index ["ticket_id"], name: "index_ticket_labels_on_ticket_id"
  end

  create_table "ticket_relationships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "relationship_type", null: false
    t.integer "source_ticket_id", null: false
    t.integer "target_ticket_id", null: false
    t.datetime "updated_at", null: false
    t.index ["source_ticket_id", "target_ticket_id", "relationship_type"], name: "idx_ticket_relationship_uniqueness", unique: true
    t.index ["source_ticket_id"], name: "index_ticket_relationships_on_source_ticket_id"
    t.index ["target_ticket_id"], name: "index_ticket_relationships_on_target_ticket_id"
  end

  create_table "tickets", force: :cascade do |t|
    t.integer "assignee_id"
    t.datetime "created_at", null: false
    t.text "description"
    t.date "due_date"
    t.integer "priority", default: 1, null: false
    t.integer "project_id", null: false
    t.integer "reporter_id", null: false
    t.integer "status", default: 0, null: false
    t.integer "story_points"
    t.integer "ticket_number", null: false
    t.integer "ticket_type", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["assignee_id"], name: "index_tickets_on_assignee_id"
    t.index ["priority"], name: "index_tickets_on_priority"
    t.index ["project_id", "ticket_number"], name: "index_tickets_on_project_id_and_ticket_number", unique: true
    t.index ["project_id"], name: "index_tickets_on_project_id"
    t.index ["reporter_id"], name: "index_tickets_on_reporter_id"
    t.index ["status"], name: "index_tickets_on_status"
    t.index ["ticket_type"], name: "index_tickets_on_ticket_type"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name"
    t.string "last_name"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "activity_logs", "tickets"
  add_foreign_key "activity_logs", "users"
  add_foreign_key "api_tokens", "users"
  add_foreign_key "comments", "tickets"
  add_foreign_key "comments", "users"
  add_foreign_key "labels", "projects"
  add_foreign_key "notifications", "tickets"
  add_foreign_key "notifications", "users", column: "actor_id"
  add_foreign_key "notifications", "users", column: "recipient_id"
  add_foreign_key "pr_links", "tickets"
  add_foreign_key "pr_links", "users"
  add_foreign_key "project_memberships", "projects"
  add_foreign_key "project_memberships", "users"
  add_foreign_key "ticket_labels", "labels"
  add_foreign_key "ticket_labels", "tickets"
  add_foreign_key "ticket_relationships", "tickets", column: "source_ticket_id"
  add_foreign_key "ticket_relationships", "tickets", column: "target_ticket_id"
  add_foreign_key "tickets", "projects"
  add_foreign_key "tickets", "users", column: "assignee_id"
  add_foreign_key "tickets", "users", column: "reporter_id"
end
