# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_09_17_143450) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.integer "record_id", null: false
    t.integer "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "archives", force: :cascade do |t|
    t.text "description"
    t.integer "experiment_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "comments", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "comment"
    t.integer "submission_id"
    t.integer "user_id"
    t.boolean "resolved", default: false
    t.boolean "posted", default: false
  end

  create_table "contributors", force: :cascade do |t|
    t.string "last_name"
    t.string "given_names"
    t.integer "experiment_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["experiment_id"], name: "index_contributors_on_experiment_id"
  end

  create_table "data_sets", force: :cascade do |t|
    t.boolean "raw", default: false
    t.string "name", null: false
    t.integer "experiment_id", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "buffer", default: "none"
    t.text "description"
    t.text "source"
    t.text "instrument_name"
  end

  create_table "data_sets_materials", id: false, force: :cascade do |t|
    t.integer "material_id", null: false
    t.integer "data_set_id", null: false
    t.index ["material_id", "data_set_id"], name: "index_data_sets_materials_on_material_id_and_data_set_id"
  end

  create_table "experiments", force: :cascade do |t|
    t.text "description", null: false
    t.text "title", null: false
    t.boolean "status", default: false, null: false
    t.text "publication"
    t.string "publication_doi"
    t.string "doi"
    t.string "bioisis_id", limit: 10
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "approved", default: false
    t.integer "user_id", default: 0, null: false
    t.integer "submission_id", null: false
    t.string "state"
    t.date "release_date"
  end

  create_table "materials", force: :cascade do |t|
    t.string "material", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "news", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "title"
    t.text "journal_info"
    t.text "abstract"
    t.text "notes"
    t.string "category"
    t.string "link"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.date "publication_date"
  end

  create_table "publications", force: :cascade do |t|
    t.string "doi"
    t.string "url"
    t.string "container_title"
    t.string "title"
    t.string "volume"
    t.string "issue"
    t.string "page"
    t.integer "year"
    t.integer "month"
    t.integer "experiment_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["experiment_id"], name: "index_publications_on_experiment_id"
  end

  create_table "real_space_files", force: :cascade do |t|
    t.decimal "rg"
    t.decimal "dmax", precision: 7, scale: 2
    t.string "method"
    t.integer "reciprocal_space_file_id", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "json"
  end

  create_table "reciprocal_space_files", force: :cascade do |t|
    t.string "sas_type", default: "subtracted"
    t.integer "data_set_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "json"
  end

  create_table "roles", force: :cascade do |t|
    t.string "role", default: "user", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "roles_users", force: :cascade do |t|
    t.integer "role_id"
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "scatter_downloads", force: :cascade do |t|
    t.string "institution"
    t.string "country"
    t.string "ip_address"
    t.string "status"
    t.string "version"
    t.integer "user_id"
    t.string "principal_investigator"
    t.boolean "email"
    t.integer "scatter_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["scatter_id"], name: "index_scatter_downloads_on_scatter_id"
    t.index ["user_id"], name: "index_scatter_downloads_on_user_id"
  end

  create_table "scatters", force: :cascade do |t|
    t.text "comments", null: false
    t.string "title", null: false
    t.string "version", null: false
    t.integer "count", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "submissions", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "data_directory", null: false
    t.integer "editing_count", default: 0, null: false
    t.boolean "status", default: true, null: false
    t.integer "user_id"
    t.string "bioisis_id", limit: 10
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.text "city"
    t.boolean "mailing_list"
    t.string "first_name"
    t.string "last_name"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "country", null: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
end
