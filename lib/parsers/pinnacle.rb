require 'open-uri'
require 'parsers/parser'

module Parser

  class Pinnacle < Parser

    @@sport_types = ['Soccer','Tennis']
    def self.sport_types; @@sport_types; end
    def self.sport_types= st; @@sport_types = st; end

    @@last = 1196336347638
    def self.last; @@last; end

    def self.create_url
      url = 'http://xml.pinnaclesports.com/pinnacleFeed.aspx'
      # url << "?" << sport_types_to_s(:url)
      url << "?last=" << (@@last - 5000).to_s
    end

    def self.update_pinnacle_feed_time doc
      @@last = doc.xpath("/pinnacle_line_feed/PinnacleFeedTime").text.to_i
    end

    def self.parse xml
      doc = Nokogiri::XML(xml) { |config| config.strict }

      update_pinnacle_feed_time doc

      event_nodes = doc.xpath("//event
        [#{sport_types_to_s 'sporttype'}]
        [periods/period[period_description='Game']/moneyline or
        periods/period[period_description='Match']/moneyline]
        [not(contains(descendant::participant_name[1], ' Sets)'))]
        ")

      event_nodes.map do |event_node|

        event = {}

        event[:sport_type] = event_node.xpath('sporttype').text
        datetime = event_node.xpath('event_datetimeGMT').text
        event[:datetime] = Time.zone.parse datetime
        event[:home] = event_node.xpath('descendant::participant[visiting_home_draw="Home"]/participant_name').text
        event[:visiting] = event_node.xpath('descendant::participant[visiting_home_draw="Visiting"]/participant_name').text

        event[:bets] = {}
        event[:bets][:moneyline] = {}
        moneyline_node = event_node.xpath("periods/period/moneyline")
        moneyline = event[:bets][:moneyline]
        moneyline[:bookmaker] = 'Pinnacle'
        odds_home = moneyline_node.xpath('moneyline_home').text.to_i
        moneyline[:odds_home] = convert_odds(odds_home)
        odds_visiting = moneyline_node.xpath('moneyline_visiting').text.to_i
        moneyline[:odds_visiting] = convert_odds(odds_visiting)
        odds_draw = moneyline_node.xpath('moneyline_draw').text
        moneyline[:odds_draw] = (odds_draw == '') ? nil : convert_odds(odds_draw.to_i)

        event
      end

    end

  end
end