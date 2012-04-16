# encoding: UTF-8
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

ActiveRecord::Schema.define(:version => 20120416083045) do

  create_table "check_categories", :force => true do |t|
    t.string   "category"
    t.string   "des"
    t.integer  "template_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "check_points", :force => true do |t|
    t.text     "content"
    t.integer  "check_category_id"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.boolean  "can_photo",         :default => false
    t.boolean  "can_video",         :default => false
  end

  create_table "check_values", :force => true do |t|
    t.string   "boolean_name"
    t.string   "int_name"
    t.string   "float_name"
    t.string   "date_name"
    t.integer  "template_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "checkers", :force => true do |t|
    t.string   "name"
    t.string   "des"
    t.string   "password_digest"
    t.integer  "organization_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "checkers", ["organization_id"], :name => "index_checkers_on_organization_id"

  create_table "organizations", :force => true do |t|
    t.string   "name"
    t.string   "phone"
    t.string   "address"
    t.string   "contact"
    t.integer  "zone_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "reports", :force => true do |t|
    t.string   "name"
    t.boolean  "supervisor_report", :default => false
    t.boolean  "worker_report",     :default => false
    t.string   "reporter_name"
    t.integer  "template_id"
    t.integer  "organization_id"
    t.string   "status"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
  end

  add_index "reports", ["organization_id"], :name => "index_reports_on_organization_id"
  add_index "reports", ["template_id"], :name => "index_reports_on_template_id"

  create_table "sessions", :force => true do |t|
    t.string   "remember_token"
    t.integer  "login_id"
    t.string   "login_type"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "sessions", ["login_id"], :name => "index_sessions_on_login_id"

  create_table "site_admins", :force => true do |t|
    t.string   "name"
    t.string   "des"
    t.string   "password_digest"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "templates", :force => true do |t|
    t.string   "name"
    t.boolean  "for_supervisor"
    t.boolean  "for_worker"
    t.integer  "zone_admin_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "password_digest"
    t.string   "des"
    t.boolean  "site_admin",                                                               :default => false
    t.boolean  "zone_admin",                                                               :default => false
    t.boolean  "zone_supervisor",                                                          :default => false
    t.boolean  "org_worker",                                                               :default => false
    t.boolean  "org_checker",                                                              :default => false
    t.datetime "created_at",                                                                                  :null => false
    t.datetime "updated_at",                                                                                  :null => false
    t.integer  "admin_id"
    t.integer  "#<ActiveRecord::ConnectionAdapters::TableDefinition:0x007f85f67a0638>_id"
    t.string   "remember_token"
  end

  add_index "users", ["name"], :name => "index_users_on_name"
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

  create_table "workers", :force => true do |t|
    t.string   "name"
    t.string   "des"
    t.string   "password_digest"
    t.integer  "organization_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "workers", ["organization_id"], :name => "index_workers_on_organization_id"

  create_table "zone_admins", :force => true do |t|
    t.string   "name"
    t.string   "des"
    t.string   "password_digest"
    t.integer  "template_max_num",       :default => 2
    t.integer  "template_max_photo_num", :default => 5
    t.integer  "template_max_video_num", :default => 1
    t.integer  "site_admin_id"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
  end

  create_table "zone_supervisor_relations", :force => true do |t|
    t.integer  "zone_id"
    t.integer  "zone_supervisor_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "zone_supervisors", :force => true do |t|
    t.string   "name"
    t.string   "des"
    t.string   "password_digest"
    t.integer  "zone_admin_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "zones", :force => true do |t|
    t.string   "name"
    t.string   "des"
    t.integer  "zone_admin_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

end
