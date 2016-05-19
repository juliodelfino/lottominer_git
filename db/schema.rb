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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160519161219) do

  create_table "articles", force: :cascade do |t|
    t.string   "title",      limit: 255
    t.text     "text",       limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "fb_users", force: :cascade do |t|
    t.string   "fb_id",      limit: 255
    t.string   "name",       limit: 255
    t.string   "email",      limit: 255
    t.string   "mobile_no",  limit: 255
    t.string   "photo",      limit: 255
    t.text     "fb_info",    limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "lotto_games", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "group_name", limit: 255
    t.string   "draw_days",  limit: 255
    t.boolean  "active"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "lotto_results", force: :cascade do |t|
    t.string   "game",           limit: 255
    t.string   "numbers",        limit: 255
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.date     "draw_date"
    t.integer  "jackpot_prize",  limit: 4
    t.integer  "winners",        limit: 4
    t.integer  "lotto_game_id",  limit: 4
    t.string   "sorted_numbers", limit: 255
  end

  create_table "user_numbers", force: :cascade do |t|
    t.string   "numbers",       limit: 255
    t.integer  "fb_user_id",    limit: 4
    t.integer  "lotto_game_id", limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

end
