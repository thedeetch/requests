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

ActiveRecord::Schema.define(:version => 20130720162953) do

  create_table "request_attachments", :force => true do |t|
    t.integer  "request_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "attachment"
  end

  create_table "request_comments", :force => true do |t|
    t.integer  "request_id"
    t.string   "user_id"
    t.string   "text"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "request_teams", :force => true do |t|
    t.integer  "request_id", :null => false
    t.integer  "team_id",    :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "request_users", :force => true do |t|
    t.integer  "request_id", :null => false
    t.string   "user_id",    :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "role"
    t.datetime "begin"
    t.datetime "end"
    t.integer  "allocation"
    t.string   "email"
  end

  create_table "requests", :force => true do |t|
    t.string   "title",             :null => false
    t.integer  "system_id",         :null => false
    t.string   "category",          :null => false
    t.string   "description",       :null => false
    t.datetime "target_date"
    t.string   "size"
    t.string   "status",            :null => false
    t.string   "user_id",           :null => false
    t.string   "behalf_of_user_id"
    t.string   "priority",          :null => false
    t.string   "context",           :null => false
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "user_email"
  end

  create_table "systems", :force => true do |t|
    t.string   "name",       :null => false
    t.integer  "team_id",    :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "teams", :force => true do |t|
    t.string   "name",         :null => false
    t.string   "directory_id", :null => false
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "versions", :force => true do |t|
    t.string   "item_type",  :null => false
    t.integer  "item_id",    :null => false
    t.string   "event",      :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

end
