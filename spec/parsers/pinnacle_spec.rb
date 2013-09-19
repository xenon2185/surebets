require 'spec_helper'
require 'parsers/pinnacle'

describe Parser::Pinnacle do

  p = Parser::Pinnacle
  p.create_dom File.join('spec','fixtures','pinnacle','201309181522.xml')

  it 'set sport types' do
    sport_types = ['Soccer']
    p.sport_types = sport_types
    expect(p.sport_types).to eq sport_types
  end

  it 'creates dom' do
    expect(p.dom.name).to eq 'document'
  end

  describe '::parse' do

    p.parse
    event = Event.where(
      sport_type: 'Soccer',
      datetime: Time.zone.parse('2013-09-18 15:14'),
      home: 'Lekhwiya Doha',
      visiting: 'Guangzhou Evergrande'
    )

    it 'creates events' do
      expect(Event.all.count).to eq 500
    end

    it 'creates event if not exists' do
      p.parse      
      expect(event.count).to eq 1
    end

    it 'creates bets' do
      expect(Bet.all.count).to eq 500
    end

    it 'creates or updates bet' do
      bet = event.first.bets.where(
        odds_home: 4.47,
        odds_visiting: 1.847,
        odds_draw: 3.85
      )
      expect(bet.count).to eq 1
    end

  end

  describe 'helpers' do
    it 'creates sport_types string' do
      p.sport_types = ['Soccer']
      expect(p.sport_types_to_s).to eq "sporttype='Soccer'"
      p.sport_types = ['Soccer', 'Tennis']
      expect(p.sport_types_to_s).to eq "sporttype='Soccer' or sporttype='Tennis'"
    end
    it 'converts odds' do
      expect(p.convert_odds -110, to: :decimal).to eq 1.909
      expect(p.convert_odds 102, to: :decimal).to eq 2.02
      expect(p.convert_odds 1.241, to: :american).to eq -415
      expect(p.convert_odds 4.580, to: :american).to eq 358
    end
  end

end