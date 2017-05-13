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

ActiveRecord::Schema.define(version: 20170513072915) do

  create_table "articles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "title"
    t.text     "text",       limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "emails", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "recipient"
    t.string   "subject"
    t.text     "body",             limit: 65535,              collation: "utf8_general_ci"
    t.datetime "plan_send_date"
    t.datetime "actual_send_date"
    t.string   "status",           limit: 10
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  create_table "fb_users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "fb_id"
    t.string   "name"
    t.string   "email"
    t.string   "mobile_no"
    t.string   "photo"
    t.text     "fb_info",    limit: 65535
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.boolean  "is_admin",                 default: false
  end

  create_table "lotto_games", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "name"
    t.string   "group_name"
    t.string   "draw_days"
    t.boolean  "active"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "current_jackpot_prize"
  end

  create_table "lotto_results", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "game"
    t.string   "numbers"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.date     "draw_date"
    t.integer  "jackpot_prize"
    t.integer  "winners"
    t.integer  "lotto_game_id"
    t.string   "sorted_numbers"
  end

  create_table "oauth_users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "email",                                default: "", null: false
    t.string   "encrypted_password",                   default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                        default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.text     "image",                  limit: 65535
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  create_table "screens", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "data_type"
    t.string   "content"
    t.string   "schedule"
    t.integer  "duration"
    t.integer  "order"
    t.boolean  "visible"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "subscriptions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "email"
    t.boolean  "enabled",                  default: true
    t.boolean  "notify_daily_results",     default: true
    t.boolean  "notify_personal_num_info", default: true
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.index ["email"], name: "index_subscriptions_on_email", unique: true, using: :btree
  end

  create_table "user_numbers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "numbers"
    t.integer  "fb_user_id"
    t.integer  "lotto_game_id"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.boolean  "won",            default: false
    t.string   "sorted_numbers"
    t.string   "status"
  end

  create_table "user_settings", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "fb_user_id"
    t.string   "email_verification"
    t.boolean  "notify_daily_results", default: true
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

end
