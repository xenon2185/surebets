require 'spec_helper'

describe Event do

  let(:event) { Event.new(sport_type: 'Soccer',
                          datetime: DateTime.now,
                          home:'A Team',
                          visiting:'B Team')}

  describe 'attributes' do

    it { expect(event).to validate_presence_of :sport_type }
    it { expect(event).to validate_presence_of :datetime }
    it { expect(event).to validate_presence_of :home }
    it { expect(event).to validate_presence_of :visiting }

    it { expect(event).to have_many :bets }

    it 'saves attributes' do
      event.save!
      expect(event).to be_valid
    end

  end

  let(:pinnacle_events) { Event.fetch :pinnacle }
  let(:bet_at_home_events) { Event.fetch :'bet-at-home' }

  describe 'refresh events and bets' do

    before :each do
      stub_pinnacle_xml
      stub_bet_at_home_xml    
    end

    it 'populates events ONLY from Pinnacle' do
      Event.refresh pinnacle_events
      # Event.refresh bet_at_home_events
      expect(Event.all.count).to eq 3
    end 

    describe 'Pinnacle' do

      it 'fetches events (with bets)' do
        expect(pinnacle_events.count).to eq 3
      end

      it 'populates bets from Pinnacle' do
        Event.refresh pinnacle_events
        expect(Event.all).to have_bet_from 'Pinnacle'
      end


    end

    describe 'Bet-at-home' do

      it 'fetches events (with bets)' do
        expect(bet_at_home_events.count).to eq 3
      end

      it 'populates bets from Bet-at-home' do
        Event.refresh pinnacle_events
        Event.refresh bet_at_home_events
        expect(Event.all).to have_bet_from 'Bet-at-home'
      end

    end

  end

  describe 'fuzzy search' do

    before :each do
      stub_pinnacle_xml
      Event.refresh pinnacle_events  
    end

    it 'searches home field' do
      expect(Event.find_by_fuzzy_home('IFK Göteborg',limit:1).first
        ).not_to eq nil
      expect(Event.find_by_fuzzy_home('sousa',limit:1).first
        ).not_to eq nil
      expect(Event.find_by_fuzzy_home('harrisson',limit:1).first
        ).to eq nil
    end

    it 'searches visiting field' do
      expect(Event.find_by_fuzzy_visiting('solna',limit:1).first
        ).not_to eq nil
      expect(Event.find_by_fuzzy_visiting('harrisson',limit:1).first
        ).not_to eq nil
    end

  end

  describe 'surebets' do

    before :each do
      stub_pinnacle_xml
      stub_bet_at_home_xml
      Event.refresh pinnacle_events
      Event.refresh bet_at_home_events
    end

    it 'finds 3x surebet' do
      expect(
        Event.first.surebets.first.profit
        ).to eq 2.255639097744361
      expect(Event.find(1).surebets.count).to eq 1
    end

    it 'finds 2x surebet' do
      expect(
        Event.find(2).surebets.refresh
        ).to eq 9.827760891590678
    end

    it 'does not find 2x surebet' do
      expect(
        Event.find(3).surebets.count
        ).to eq 0
    end

  end

end