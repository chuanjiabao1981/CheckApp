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

ActiveRecord::Schema.define(:version => 20120414012337) do

  create_table "admins", :force => true do |t|
    t.string   "name"
    t.string   "password_digest"
    t.string   "des"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "contact"
    t.string   "phone"
  end

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

  create_table "templates", :force => true do |t|
    t.string   "name"
    t.boolean  "for_supervisor"
    t.boolean  "for_worker"
    t.integer  "admin_id"
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
    t.integer  "#<ActiveRecord::ConnectionAdapters::TableDefinition:0x007fa8e3659ee0>_id"
    t.string   "remember_token"
  end

  add_index "users", ["name"], :name => "index_users_on_name"
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

end
