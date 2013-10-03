require 'spec_helper'

describe Surebet do

  let(:event) { Event.create!(sport_type: 'Soccer',
                              datetime: DateTime.now,
                              home:'A Team',
                              visiting:'B Team')}

  let(:surebet) { event.surebets.build(
                    bet_with_odds_home_id: 1,
                    bet_with_odds_visiting_id: 1,
                    bet_with_odds_draw_id: 1,
                    profit: 2.2134958)}

  describe 'attributes' do

    it { expect(surebet).to validate_presence_of :bet_with_odds_home_id }
    it { expect(surebet).to validate_presence_of :bet_with_odds_visiting_id }
    it { expect(surebet).to validate_presence_of :profit }

    it { expect(surebet).to belong_to :event }

    it 'saves attributes' do
      surebet.save!
      expect(surebet).to be_valid
    end

  end

end
