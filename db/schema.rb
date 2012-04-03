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

ActiveRecord::Schema.define(:version => 20120403080600) do

  create_table "admins", :force => true do |t|
    t.string   "name"
    t.string   "password_digest"
    t.string   "des"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "contact"
    t.string   "phone"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "password_digest"
    t.string   "des"
    t.boolean  "site_admin",                                                               :default => false
    t.boolean  "admin",                                                                    :default => false
    t.boolean  "supervisor",                                                               :default => false
    t.boolean  "worker",                                                                   :default => false
    t.boolean  "checker",                                                                  :default => false
    t.datetime "created_at",                                                                                  :null => false
    t.datetime "updated_at",                                                                                  :null => false
    t.integer  "admin_id"
    t.integer  "#<ActiveRecord::ConnectionAdapters::TableDefinition:0x007fa8e3659ee0>_id"
  end

end
