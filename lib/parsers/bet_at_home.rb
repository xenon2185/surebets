require 'open-uri'
require 'parsers/parser'

class NoWaitError < StandardError; end

module Parser

  class BetAtHome < Parser

    @@sport_types = ['Football','Tennis']
    def self.sport_types; @@sport_types; end
    def self.sport_types= st; @@sport_types = st; end

    def self.create_url
        url = 'http://www.bet-at-home.com/en/feed/sport'
    end

    def self.parse xml

      if xml.length < 200 && xml.read.include?("Please use a minimum interval of 60 sec")
        xml.rewind
        xml.read =~ /please wait for (\d\d?)/
        raise NoWaitError, $1
      end

      doc = Nokogiri::XML(xml) #{ |config| config.strict }

      # When using various bet types:
      # first find unique events ie. [not(preceding::MatchId = MatchId)]
      # then find odds for particular event ex. [MatchId = '1173020']

      event_nodes = doc.xpath("//OddsObject
        [#{sport_types_to_s 'Sport'}]
        [OddsType='2W' or OddsType='3W']
        ")

      event_nodes.map do |event_node|

        event = {}

        sport_type = event_node.xpath('Sport').text
        sport_type = 'Soccer' if sport_type == 'Football'
        event[:sport_type] = sport_type

        datetime = event_node.xpath('Date').text
        event[:datetime] = Time.zone.parse datetime

        event[:home] = event_node.xpath('OddsData/HomeTeam').text
        event[:visiting] = event_node.xpath('OddsData/AwayTeam').text

        event[:bets] = {}
        event[:bets][:moneyline] = {}
        moneyline_node = event_node.xpath("OddsData")

        moneyline = event[:bets][:moneyline]
        moneyline[:bookmaker] = 'Bet-at-home'
        moneyline[:odds_home] = moneyline_node.xpath('HomeOdds').text.to_f
        moneyline[:odds_visiting] = moneyline_node.xpath('AwayOdds').text.to_f
        odds_draw = moneyline_node.xpath('DrawOdds').text
        moneyline[:odds_draw] = (odds_draw == '') ? nil : odds_draw.to_f

        event

      end
      
    end

  end

end