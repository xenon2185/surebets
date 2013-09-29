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

  describe 'refresh events and bets' do

    let(:pinnacle_events) { Event.fetch :pinnacle }
    let(:bet_at_home_events) { Event.fetch :'bet-at-home' }

    before :each do
      stub_pinnacle_xml
      stub_bet_at_home_xml        
    end

    it 'populates events ONLY from Pinnacle' do
      Event.refresh pinnacle_events
      Event.refresh bet_at_home_events
      expect(Event.all.count).to eq 1
    end 

    describe 'Pinnacle' do

      it 'fetches events (with bets)' do
        expect(pinnacle_events.count).to eq 1
      end

      it 'populates bets from Pinnacle' do
        Event.refresh pinnacle_events
        expect(Event.all).to have_bet_from 'Pinnacle'
      end


    end

    describe 'Bet-at-home' do

      it 'fetches events (with bets)' do
        expect(bet_at_home_events.count).to eq 1
      end

      # it 'populates bets from Pinnacle' do
      #   Event.refresh bet_at_home_events
      #   expect(Bet.where(bookmaker: 'Pinnacle').count).to eq 1
      # end


    end

  end

end