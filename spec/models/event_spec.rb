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

    describe 'Pinnacle' do

      before :each do
        stub_pinnacle_xml        
      end

      it 'populates events ONLY from Pinnacle' do
        Event.refresh 'Pinnacle'
        expect(Event.all.count).to eq 186
      end

      it 'populates bets from Pinnacle' do
        Event.refresh 'Pinnacle'
        expect(Bet.where(bookmaker: 'Pinnacle').count).to eq 186
      end


    end

  end

end