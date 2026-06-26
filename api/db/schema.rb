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

ActiveRecord::Schema[8.1].define(version: 2026_06_26_120000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.string "event_name", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_events_on_discarded_at"
  end

  create_table "user_join_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.uuid "event_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["discarded_at"], name: "index_user_join_events_on_discarded_at"
    t.index ["event_id"], name: "index_user_join_events_on_event_id"
    t.index ["user_id", "event_id"], name: "index_user_join_events_on_user_event_active", unique: true, where: "(discarded_at IS NULL)"
    t.index ["user_id"], name: "index_user_join_events_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_users_on_discarded_at"
  end

  add_foreign_key "user_join_events", "events"
  add_foreign_key "user_join_events", "users"
end
