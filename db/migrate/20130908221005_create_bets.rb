class CreateBets < ActiveRecord::Migration
  def change
    create_table :bets do |t|
        t.string :bookmaker
        t.decimal :odds_home
        t.decimal :odds_visiting
        t.decimal :odds_draw
    end
    add_reference :bets, :event, index: true
  end
end
