require 'spec_helper'

describe Bet do
  
  let(:event) { Event.create!(sport_type: 'Soccer',
                              datetime: DateTime.now,
                              home:'A Team',
                              visiting:'B Team')}

  let(:bet) { event.bets.build(bookmaker: 'Pinnacle',
                               odds_home: 1.9,
                               odds_visiting: 1.9)}

  describe 'attributes' do

    it { expect(bet).to validate_presence_of :event_id }
    it { expect(bet).to validate_presence_of :bookmaker }
    it { expect(bet).to validate_presence_of :odds_home }
    it { expect(bet).to validate_presence_of :odds_visiting }

    it { expect(bet).to belong_to :event }

    it 'saves attributes' do
      bet.save!
      expect(bet).to be_valid
    end

  end

end