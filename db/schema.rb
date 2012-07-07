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

ActiveRecord::Schema.define(:version => 20120706122717) do

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
    t.boolean  "can_photo",         :default => false
    t.boolean  "can_video",         :default => false
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
  end

  create_table "check_values", :force => true do |t|
    t.string   "boolean_name"
    t.string   "int_name"
    t.string   "float_name"
    t.string   "date_name"
    t.string   "text_name"
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

  create_table "equipment", :force => true do |t|
    t.string   "serial_num"
    t.date     "expire_date"
    t.string   "equipment_type"
    t.text     "des"
    t.integer  "zone_admin_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "equipment", ["serial_num"], :name => "index_equipment_on_serial_num"

  create_table "media_infos", :force => true do |t|
    t.string   "video_path"
    t.string   "photo_path"
    t.string   "media_type"
    t.integer  "report_record_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "organizations", :force => true do |t|
    t.string   "name"
    t.string   "phone"
    t.string   "address"
    t.string   "contact"
    t.integer  "zone_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "report_records", :force => true do |t|
    t.integer  "report_id"
    t.integer  "check_point_id"
    t.integer  "check_category_id"
    t.boolean  "boolean_value",     :default => false
    t.integer  "int_value",         :default => 0
    t.float    "float_value",       :default => 0.0
    t.date     "date_value",        :default => '2011-12-03'
    t.text     "text_value",        :default => ""
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
  end

  add_index "report_records", ["check_point_id"], :name => "index_report_records_on_check_point_id"
  add_index "report_records", ["report_id"], :name => "index_report_records_on_report_id"

  create_table "reports", :force => true do |t|
    t.string   "reporter_name"
    t.integer  "template_id"
    t.integer  "organization_id"
    t.integer  "committer_id"
    t.string   "committer_type"
    t.string   "status"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
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
    t.integer  "template_max_num",        :default => 2
    t.integer  "template_max_photo_num",  :default => 5
    t.integer  "template_max_video_num",  :default => 1
    t.integer  "site_admin_id"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.integer  "check_point_photo_num",   :default => 2
    t.integer  "check_point_video_num",   :default => 1
    t.integer  "max_org_num",             :default => 5
    t.integer  "max_zone_supervisor_num", :default => 5
    t.integer  "max_backup_month",        :default => 10
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
