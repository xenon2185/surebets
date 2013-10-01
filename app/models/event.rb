class Event < ActiveRecord::Base

  fuzzily_searchable :home, :visiting

  has_many :bets, dependent: :destroy do

    # association extension
    def refresh bets, bookmaker, options={reverse: false}
      moneyline = bets[:moneyline]
      if options[:reverse]
        moneyline[:odds_home], moneyline[:odds_visiting] = moneyline[:odds_visiting], moneyline[:odds_home]
      end
      if where(bookmaker: bookmaker).empty?
        create moneyline
      else
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

  def self.fetch bookmaker
    bookmaker = bookmaker.to_s.titleize.gsub(' ','')
    parser = ('Parser::' + bookmaker).constantize
    events = parser.fetch 
  end

  def self.refresh events
    unless events.empty?
      bookmaker = events.first[:bets][:moneyline][:bookmaker]
      if bookmaker == 'Pinnacle'
        create_events events
      else
        find_events events
      end
    end
  end

  def self.create_events events
    events.each do |attributes|
      bets = attributes.delete(:bets)
      event = find_or_create_by(attributes)
      event.bets.refresh bets, 'Pinnacle'
    end
  end

  def self.find_events events
    # puts "#{events.count} Bet-at-home events"

    events.each do |attributes|
      bets = attributes.delete(:bets)

      events_q = where(sport_type: attributes[:sport_type])

      dt = attributes[:datetime]
      events_q = events_q.where(datetime: (dt-14.hours)..(dt+12.hours))

      # puts "Fuzzy searching #{events_q.count} events"

      reverse = false
      events_a = events_q.find_by_fuzzy_home(attributes[:home], limit:3).compact!

      if events_a == nil || events_a.first == nil

        # puts "Not found home #{attributes[:home]}"

        events_a = events_q.find_by_fuzzy_visiting(attributes[:home], limit:3).compact!
        next if events_a == nil || events_a.first == nil
        # switched home/visiting teams/player
        reverse = true
        visiting = events_a.first.visiting

        # puts "Found home team: #{visiting}"

        events_q = events_q.where(visiting: visiting)

        events_a = events_q.find_by_fuzzy_home(attributes[:visiting], limit:3).compact!
        next if events_a == nil || events_a.first == nil
        event = events_a.first
      else
        home = events_a.first.home

        # puts "Found home team: #{home}"

        events_q = events_q.where(home: home)

        events_a = events_q.find_by_fuzzy_visiting(attributes[:visiting], limit:3).compact!
        next if events_a == nil || events_a.first == nil
        event = events_a.first
      end

      # if !reverse
      #   puts "#{event.home} | #{attributes[:home]}\t\t-\t\t#{event.visiting} | #{attributes[:visiting]}"
      # else
      #   puts "#{event.home} | #{attributes[:visiting]}\t\t-\t\t#{event.visiting} | #{attributes[:home]}"
      # end

      event.bets.refresh bets, 'Bet-at-home', reverse: reverse

    end
  end

end