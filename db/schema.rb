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

ActiveRecord::Schema[7.0].define(version: 2026_05_22_132336) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "add_expense_saved_inputs", force: :cascade do |t|
    t.string "document_id"
    t.string "date"
    t.string "amount"
    t.string "category"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "alias"
  end

  create_table "command_settings", force: :cascade do |t|
    t.bigint "user_id"
    t.string "savable_input_type"
    t.bigint "savable_input_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type"
  end

  create_table "expenses", force: :cascade do |t|
    t.bigint "spreadsheet_id", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.date "date", null: false
    t.string "category", null: false
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "layout_actions", force: :cascade do |t|
    t.string "layout", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "spreadsheet_forms", force: :cascade do |t|
    t.bigint "spreadsheet_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "spreadsheets", force: :cascade do |t|
    t.string "document_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "expense_range"
    t.string "rest_balance_cell"
    t.string "alias"
    t.index ["alias", "user_id"], name: "index_spreadsheets_on_alias_and_user_id", unique: true
    t.index ["document_id"], name: "index_spreadsheets_on_document_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "telegram_username", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
