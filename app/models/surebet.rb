class Surebet < ActiveRecord::Base

  belongs_to :event

  validates :bet_with_odds_home_id, 
            :bet_with_odds_visiting_id,
            :profit,
            presence: true

end
