require 'parsers/bet_at_home'
require_relative '../../support/factory'
require_relative '../../support/match_date'

describe Parser::BetAtHome do
  
  p = Parser::BetAtHome
  let(:xml) { Factory.xml_feed 'Bet-at-home' }

  describe '::parse' do

    let(:events)  { p.parse xml }
    let(:event)   { events.first }

    describe 'event' do

      it "extracts sport type" do
        sport_type = 'Soccer'
        expect(event[:sport_type]).to eq sport_type
      end

      it "extracts event datetime" do
        datetime = '2013-09-23 13:00'
        expect(event[:datetime]).to match_date datetime
      end

      it "extracts home team/player" do
        home = 'AC Sparta Praha U21'
        expect(event[:home]).to eq home
      end

      it "extracts visiting team/player" do
        visiting = 'FK Varnsdorf U21'
        expect(event[:visiting]).to eq visiting
      end

      describe 'bets' do

        describe 'moneyline' do

          let(:moneyline) { event[:bets][:moneyline] }

          it "assign bookmaker" do
            expect(moneyline[:bookmaker]).to eq 'Bet-at-home'
          end

          it "extracts odds for home team/player" do
            expect(moneyline[:odds_home]).to eq 1.15
          end

          it "extracts odds for visiting team/player" do
            expect(moneyline[:odds_visiting]).to eq 8.50
          end

          it "extracts odds for draw" do
            expect(moneyline[:odds_draw]).to eq 6.50
          end

        end

      end

    end

  end

  describe '::fetch' do

    let(:events) { p.fetch }

    context "success" do

      before :each do
        p.stub(:get).and_return(xml)
      end

      it 'build events objects' do
        expect(events.count).to eq 519
      end

    end

    context "bad XML" do

      before :each do
        p.stub(:get).and_return("Bad XML")
      end

      it "raise error from Nokogiri" do
        expect {
          events.length
        }.to raise_error(Nokogiri::XML::SyntaxError)
      end

    end    

  end

  describe 'helpers' do
    describe '::sport_types_to_s' do
      it 'creates xpath string' do
        p.sport_types = ['Football', 'Tennis']
        expect(p.sport_types_to_s 'Sport').to eq "Sport='Football' or Sport='Tennis'"
      end
    end
  end

end