class Event < ActiveRecord::Base

  fuzzily_searchable :home, :visiting

  has_many :surebets, dependent: :destroy do
    
    def refresh
      destroy_all
      bets = proxy_association.owner.bets
      if bets.count == 2
        if bets.all? {|bet| bet.odds_draw != nil}
          refresh_3x
        elsif bets.all? {|bet| bet.odds_draw == nil}
          refresh_2x
        end
      end
    end

    def refresh_2x
      bet1 = proxy_association.owner.bets.first
      bet2 = proxy_association.owner.bets.last
      bet_with_odds_home     = [bet1, bet2].max { |a, b| a.odds_home <=> b.odds_home }
      bet_with_odds_visiting = [bet1, bet2].max { |a, b| a.odds_visiting <=> b.odds_visiting }

      cost = 1/bet_with_odds_home.odds_home + 
             1/bet_with_odds_visiting.odds_visiting

      if cost < 1
        # create surebet
        create(
          bet_with_odds_home_id: bet_with_odds_home.id,
          bet_with_odds_visiting_id: bet_with_odds_visiting.id,
          profit: profit = (1 - cost) * 100
          )
        profit.to_f
      end
      
    end

    def refresh_3x
      bet1 = proxy_association.owner.bets.first
      bet2 = proxy_association.owner.bets.last
      bet_with_odds_home     = [bet1, bet2].max { |a, b| a.odds_home <=> b.odds_home }
      bet_with_odds_visiting = [bet1, bet2].max { |a, b| a.odds_visiting <=> b.odds_visiting }
      bet_with_odds_draw     = [bet1,bet2].max { |a, b| a.odds_draw <=> b.odds_draw }

      cost = 1/bet_with_odds_home.odds_home + 
             1/bet_with_odds_visiting.odds_visiting + 
             1/bet_with_odds_draw.odds_draw

      if cost < 1
        # create surebet
        create(
          bet_with_odds_home_id: bet_with_odds_home.id,
          bet_with_odds_visiting_id: bet_with_odds_visiting.id,
          bet_with_odds_draw_id: bet_with_odds_draw.id,
          profit: profit = (1 - cost) * 100
          )
        profit.to_f
      end
    end

  end

  has_many :bets, dependent: :destroy do

    # association extension
    def refresh bets, bookmaker, options={reverse: false}
      moneyline = bets[:moneyline]

      if options[:reverse]
        moneyline[:odds_home], moneyline[:odds_visiting] = moneyline[:odds_visiting], moneyline[:odds_home]
      end

      if where(bookmaker: bookmaker).empty?
        create moneyline
        proxy_association.owner.surebets.refresh
      else
        bet = where(bookmaker: bookmaker).first
        unless bet.odds_home == moneyline[:odds_home] &&
               bet.odds_visiting == moneyline[:odds_visiting] &&
               bet.odds_draw == moneyline[:odds_draw]
          bet.update_attributes(
              odds_home: moneyline[:odds_home],
              odds_visiting: moneyline[:odds_visiting],
              odds_draw: moneyline[:odds_draw]
            )
          proxy_association.owner.surebets.refresh
        end
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

  # def self.test_find_events events
  #   events.each do |attributes|

  #     events_q = where(sport_type: attributes[:sport_type])

  #     dt = attributes[:datetime]
  #     events_q = events_q.where(datetime: (dt-14.hours)..(dt+12.hours))
  #     events_a = events_q.find_by_fuzzy_home(attributes[:home],limit:3)
  #     event = events_a.detect {|e| e != nil}

  #     puts event.inspect

  #   end
  # end

  def self.find_events events
    # puts "#{events.count} Bet-at-home events"

    events.each do |attributes|
      bets = attributes.delete(:bets)

      # filtering events by sport_type and datetime before fuzzy searching
      events_q = where(sport_type: attributes[:sport_type])

      dt = attributes[:datetime]
      events_q = events_q.where(datetime: (dt-14.hours)..(dt+12.hours))

      # puts "Fuzzy searching #{events_q.count} events"

      reverse = false
      events_a = events_q.find_by_fuzzy_home(attributes[:home], limit:3)
      event = events_a.detect {|e| e != nil}

      if event == nil

        # puts "Not found home #{attributes[:home]}"

        events_a = events_q.find_by_fuzzy_visiting(attributes[:home], limit:3)
        event = events_a.detect {|e| e != nil}
        next if event == nil
        # switched home/visiting teams/player
        reverse = true
        visiting = event.visiting

        # puts "Found home team: #{visiting}"

        events_q = events_q.where(visiting: visiting)

        events_a = events_q.find_by_fuzzy_home(attributes[:visiting], limit:3)
        event = events_a.detect {|e| e != nil}
        next if event == nil

      else
        home = event.home

        # puts "Found home team: #{home}"

        events_q = events_q.where(home: home)

        events_a = events_q.find_by_fuzzy_visiting(attributes[:visiting], limit:3)
        event = events_a.detect {|e| e != nil}
        next if event == nil
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