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

ActiveRecord::Schema.define(version: 20140504201508) do

  create_table "game_hotels", force: true do |t|
    t.integer  "share_price"
    t.integer  "chain_size"
    t.string   "tiles"
    t.integer  "game_id"
    t.integer  "hotel_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  create_table "game_player_stock_cards", force: true do |t|
    t.integer  "game_player_id"
    t.integer  "stock_card_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "game_player_tiles", force: true do |t|
    t.integer  "game_player_id"
    t.integer  "tile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "game_players", force: true do |t|
    t.integer  "game_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cash",       default: 0
    t.integer  "turn_order"
    t.string   "username"
  end

  add_index "game_players", ["game_id"], name: "index_game_players_on_game_id"
  add_index "game_players", ["user_id"], name: "index_game_players_on_user_id"

  create_table "game_stock_cards", force: true do |t|
    t.integer  "game_id"
    t.integer  "stock_card_id"
    t.integer  "price"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "game_tiles", force: true do |t|
    t.integer  "game_id"
    t.integer  "tile_id"
    t.string   "hotel"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "available"
    t.boolean  "placed"
    t.string   "cell"
  end

  create_table "games", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "up_next"
    t.integer  "bank"
    t.integer  "merger"
    t.string   "merger_up_next"
    t.integer  "has_shares"
    t.string   "acquired_hotel"
    t.string   "dominant_hotel"
    t.boolean  "buy_stocks"
  end

  create_table "hotels", force: true do |t|
    t.string   "name"
    t.string   "color"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "log_entries", force: true do |t|
    t.string   "message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "game_id"
  end

  create_table "notifications", force: true do |t|
    t.string   "message"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stock_cards", force: true do |t|
    t.string   "hotel"
    t.integer  "price"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "card_number"
  end

  create_table "tiles", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "row"
    t.integer  "column"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  add_index "users", ["username"], name: "index_users_on_username", unique: true

end
