class CreateSurebets < ActiveRecord::Migration
  def change
    create_table :surebets do |t|
      t.integer :bet_with_odds_home_id
      t.integer :bet_with_odds_visiting_id
      t.integer :bet_with_odds_draw_id
      t.decimal :profit
    end
    add_reference :surebets, :event, index: true
  end
end
