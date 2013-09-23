require 'spec_helper'
require 'parsers/pinnacle'

describe Parser::Pinnacle do

  p = Parser::Pinnacle
  p.create_dom File.join('spec','fixtures','pinnacle','201309231021.xml')
  # p.create_dom

  it 'set sport types' do
    sport_types = ['Soccer']
    p.sport_types = sport_types
    expect(p.sport_types).to eq sport_types
  end

  it 'creates dom' do
    expect(p.dom.name).to eq 'document'
  end

  # it 'creates url' do
  #   p.sport_types = ['Soccer', 'Tennis']
  #   url = p.create_url
  #   expect(url).to eq 'http://xml.pinnaclesports.com/pinnacleFeed.aspx?sportType=Soccer&sportType=Tennis&last=1379510424874'
  # end

  describe '::parse' do

    p.parse
    event = Event.where(
      sport_type: 'Soccer',
      datetime: Time.zone.parse('2013-09-23 17:04'),
      home: 'IFK Goteborg',
      visiting: 'AIK Solna'
    )

    it 'updates PinnacleFeedTime' do
      expect(p.last).to eq 1379931647048
    end

    it 'creates events' do
      expect(Event.all.count).to eq 182
    end

    it 'creates event if not exists' do
      p.parse      
      expect(event.count).to eq 1
    end

    it 'creates bets' do
      expect(Bet.all.count).to eq 182
    end

    it 'creates or updates bet' do
      bet = event.first.bets.where(
        odds_home: p.convert_odds(131, to: :decimal),
        odds_visiting: p.convert_odds(224, to: :decimal),
        odds_draw: p.convert_odds(247, to: :decimal)
      )
      expect(bet.count).to eq 1
    end

  end

  describe 'helpers' do
    describe '::sport_types_to_s' do
      it 'creates xpath string' do
        p.sport_types = ['Soccer']
        expect(p.sport_types_to_s :xpath).to eq "sporttype='Soccer'"
        p.sport_types = ['Soccer', 'Tennis']
        expect(p.sport_types_to_s :xpath).to eq "sporttype='Soccer' or sporttype='Tennis'"
      end
      # it 'creates url string' do
      #   p.sport_types = ['Soccer']
      #   expect(p.sport_types_to_s :url).to eq "sportType=Soccer"
      #   p.sport_types = ['Soccer', 'Tennis']
      #   expect(p.sport_types_to_s :url).to eq "sportType=Soccer&sportType=Tennis"
      # end
    end
    it 'converts odds' do
      expect(p.convert_odds -110, to: :decimal).to eq 1.909
      expect(p.convert_odds 102, to: :decimal).to eq 2.02
      expect(p.convert_odds 1.241, to: :american).to eq -415
      expect(p.convert_odds 4.580, to: :american).to eq 358
    end
  end

end