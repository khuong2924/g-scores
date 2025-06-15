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

ActiveRecord::Schema[7.0].define(version: 2025_06_14_000002) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "raw_scores", force: :cascade do |t|
    t.string "registration_number", null: false
    t.string "name"
    t.decimal "toan", precision: 4, scale: 2
    t.decimal "ngu_van", precision: 4, scale: 2
    t.decimal "ngoai_ngu", precision: 4, scale: 2
    t.string "ma_ngoai_ngu"
    t.decimal "vat_li", precision: 4, scale: 2
    t.decimal "hoa_hoc", precision: 4, scale: 2
    t.decimal "sinh_hoc", precision: 4, scale: 2
    t.decimal "lich_su", precision: 4, scale: 2
    t.decimal "dia_li", precision: 4, scale: 2
    t.decimal "gdcd", precision: 4, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["registration_number"], name: "index_raw_scores_on_registration_number", unique: true
  end

end
