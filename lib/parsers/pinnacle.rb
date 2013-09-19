require 'open-uri'

module Parser

  class Pinnacle

    @@sport_types = ['Soccer','Tennis']
    def self.sport_types; @@sport_types; end
    def self.sport_types= st; @@sport_types = st; end

    @@xml_url = 'http://xml.pinnaclesports.com/pinnacleFeed.aspx'

    @@dom = nil
    def self.dom; @@dom; end

    def self.create_dom path = @@xml_url
      @@dom = Nokogiri::XML(open(path))
    end

    def self.sport_types_to_s
      sport_types= @@sport_types.clone
      sport_types_string = "sporttype='#{sport_types.shift}'"
      sport_types.each do |sport_type|
        sport_types_string << " or sporttype='#{sport_type}'"
      end
      sport_types_string
    end

    def self.convert_odds odds, options = {to: :decimal}
      case options[:to]
      when :decimal
        if odds < 0
          (100.0/odds.abs + 1).round 3
        else
          (odds/100.0 + 1).round 3
        end
      when :american
        if odds < 2
          (-100/(odds-1)).round
        else
          ((odds-1)*100).round
        end
      end
    end

    def self.parse
      event_nodes = @@dom.xpath("//event[(#{sport_types_to_s})
        and descendant::period_description='Game']  ")

      create_events event_nodes

    end

    private
      def self.create_events event_nodes

        event_nodes.each do |event_node|
          event = {}
          event[:sport_type] = event_node.xpath('sporttype').text
          datetime = event_node.xpath('event_datetimeGMT').text
          event[:datetime] = Time.zone.parse(datetime)
          event[:home] = event_node.xpath('descendant::participant[visiting_home_draw="Home"]/participant_name').text
          event[:visiting] = event_node.xpath('descendant::participant[visiting_home_draw="Visiting"]/participant_name').text
          event = Event.find_or_create_by(event)
          create_bets event_node, event
        end

      end

      def self.create_bets event_node, event

        moneyline = event_node.xpath("descendant::period[period_description='Game']/moneyline")

        bet = {bookmaker: 'Pinnacle'}
        odds_home = moneyline.xpath('moneyline_home').text.to_i
        bet[:odds_home] = convert_odds(odds_home)
        odds_visiting = moneyline.xpath('moneyline_visiting').text.to_i
        bet[:odds_visiting] = convert_odds(odds_visiting)
        odds_draw = moneyline.xpath('moneyline_draw').text.to_i
        bet[:odds_draw] = convert_odds(odds_draw)

        bet = event.bets.build(bet)

        if event.bets.where(bookmaker: 'Pinnacle').exists?
          existing_bet = event.bets.where(bookmaker: 'Pinnacle').first
          existing_bet.update_attributes(
            odds_home: bet[:odds_home],
            odds_visiting: bet[:odds_visiting],
            odds_draw: bet[:odds_draw]
          )
        else
          bet.save
        end

      end

  end
end