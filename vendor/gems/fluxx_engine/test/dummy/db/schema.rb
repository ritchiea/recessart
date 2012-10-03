# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100714054627) do

  create_table "audits", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "auditable_id"
    t.string   "auditable_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "username"
    t.string   "action"
    t.text     "audit_changes"
    t.integer  "version",        :default => 0
    t.string   "comment"
    t.text     "full_model"
  end

  add_index "audits", ["auditable_id", "auditable_type"], :name => "auditable_index"
  add_index "audits", ["created_at"], :name => "index_audits_on_created_at"
  add_index "audits", ["user_id", "user_type"], :name => "user_index"

  create_table "client_stores", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "client_store_type"
    t.string   "name"
    t.datetime "deleted_at"
    t.text     "data"
  end

  add_index "client_stores", ["user_id", "client_store_type"], :name => "index_client_stores_on_user_id_and_client_store_type"
  add_index "client_stores", ["user_id"], :name => "index_client_stores_on_user_id"

  create_table "instruments", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.datetime "date_of_birth"
    t.datetime "deleted_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.datetime "locked_until"
    t.integer  "locked_by_id"
    t.integer  "price"
    t.integer  "first_instrument_id"
  end

  create_table "multi_element_choices", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "target_id",              :limit => 12, :null => false
    t.integer  "multi_element_value_id", :limit => 12, :null => false
  end

  add_index "multi_element_choices", ["target_id", "multi_element_value_id"], :name => "multi_element_choices_index_cl_attr_val", :unique => true

  create_table "multi_element_groups", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "target_class_name", :null => false
    t.string   "name"
    t.string   "description"
  end

  create_table "multi_element_values", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "description"
    t.string   "value"
    t.integer  "multi_element_group_id",           :limit => 12
    t.integer  "dependent_multi_element_value_id"
  end

  add_index "multi_element_values", ["multi_element_group_id"], :name => "index_multi_element_values_on_multi_element_group_id"

  create_table "musician_instruments", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "musician_id"
    t.integer  "instrument_id"
  end

  create_table "musicians", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "music_type_id"
    t.string   "street_address"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.datetime "date_of_birth"
  end

  create_table "orchestras", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.datetime "locked_until"
    t.integer  "locked_by_id"
  end

  create_table "realtime_updates", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "action",                         :null => false
    t.integer  "user_id",          :limit => 12
    t.integer  "model_id",         :limit => 12, :null => false
    t.string   "type_name",                      :null => false
    t.string   "model_class",                    :null => false
    t.text     "delta_attributes",               :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
