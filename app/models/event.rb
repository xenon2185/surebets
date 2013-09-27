class Event < ActiveRecord::Base

  has_many :bets, dependent: :destroy do

    # association extension
    def refresh bets, bookmaker
      moneyline = bets[:moneyline]
      if where(bookmaker: bookmaker).empty?
        create moneyline
      else
        delete
        where(bookmaker: bookmaker).first.update_attributes(
            odds_home: moneyline[:odds_home],
            odds_visiting: moneyline[:odds_visiting],
            odds_draw: moneyline[:odds_draw]
          )
      end
    end

  end

  validates :sport_type, :datetime, :home, :visiting, presence: true

  scope :sport_types, lambda { distinct.pluck :sport_type }

  def self.refresh bookmaker
    parser = ('Parser::' + bookmaker).constantize
    events = parser.fetch
    if bookmaker == 'Pinnacle'
      create_events events
    end
  end

  def self.create_events events
    events.each do |attributes|
      bets = attributes.delete(:bets)
      event = find_or_create_by(attributes)
      event.bets.refresh bets, 'Pinnacle'
    end
  end

end