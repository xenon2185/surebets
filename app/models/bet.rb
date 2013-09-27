class Bet < ActiveRecord::Base

  belongs_to :event

  validates :event_id, :bookmaker, :odds_home, :odds_visiting, presence: true

end