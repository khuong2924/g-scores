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

ActiveRecord::Schema[7.0].define(version: 2025_06_13_090021) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "scores", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.bigint "subject_id", null: false
    t.float "score", null: false
    t.string "english_level"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["student_id", "subject_id"], name: "index_scores_on_student_id_and_subject_id", unique: true
    t.index ["student_id"], name: "index_scores_on_student_id"
    t.index ["subject_id"], name: "index_scores_on_subject_id"
  end

  create_table "students", force: :cascade do |t|
    t.string "registration_number"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["registration_number"], name: "index_students_on_registration_number", unique: true
  end

  create_table "subjects", force: :cascade do |t|
    t.string "code", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_subjects_on_code", unique: true
  end

  add_foreign_key "scores", "students"
  add_foreign_key "scores", "subjects"
end
