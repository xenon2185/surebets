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

ActiveRecord::Schema.define(version: 20131001125453) do

  create_table "bets", force: true do |t|
    t.string  "bookmaker"
    t.decimal "odds_home"
    t.decimal "odds_visiting"
    t.decimal "odds_draw"
    t.integer "event_id"
  end

  add_index "bets", ["event_id"], name: "index_bets_on_event_id"

  create_table "events", force: true do |t|
    t.string   "sport_type"
    t.datetime "datetime"
    t.string   "home"
    t.string   "visiting"
  end

  create_table "surebets", force: true do |t|
    t.integer "bet_with_odds_home_id"
    t.integer "bet_with_odds_visiting_id"
    t.integer "bet_with_odds_draw_id"
    t.decimal "profit"
    t.integer "event_id"
  end

  add_index "surebets", ["event_id"], name: "index_surebets_on_event_id"

  create_table "trigrams", force: true do |t|
    t.string  "trigram",     limit: 3
    t.integer "score",       limit: 2
    t.integer "owner_id"
    t.string  "owner_type"
    t.string  "fuzzy_field"
  end

  add_index "trigrams", ["owner_id", "owner_type", "fuzzy_field", "trigram", "score"], name: "index_for_match"
  add_index "trigrams", ["owner_id", "owner_type"], name: "index_by_owner"

end
