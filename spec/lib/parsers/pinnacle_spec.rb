# require 'parsers/pinnacle'
# require_relative '../../support/factory'
# require_relative '../../support/match_date'
require 'spec_helper'

describe Parser::Pinnacle do

  p = Parser::Pinnacle
  let(:xml) { Factory.xml_feed 'Pinnacle' }

  it "updates PinnacleFeedTime" do
    expect(p.update_pinnacle_feed_time(Nokogiri::XML(xml))).to eq 1379931647048
  end

  describe '::parse' do

    let(:events)  { p.parse xml }
    let(:event)   { events.first }

    describe 'event' do

      it "extracts sport type" do
        sport_type = 'Soccer'
        expect(event[:sport_type]).to eq sport_type
      end

      it "extracts event datetime" do
        datetime = '2013-09-23 17:04'
        expect(event[:datetime]).to match_date datetime
      end

      it "extracts home team/player" do
        home = 'IFK Goteborg'
        expect(event[:home]).to eq home
      end

      it "extracts visiting team/player" do
        visiting = 'AIK Solna'
        expect(event[:visiting]).to eq visiting
      end

      describe 'bets' do

        describe 'moneyline' do

          let(:moneyline) { event[:bets][:moneyline] }

          it "assign bookmaker" do
            expect(moneyline[:bookmaker]).to eq 'Pinnacle'
          end

          it "extracts odds for home team/player" do
            odds_home = p.convert_odds(131, to: :decimal)
            expect(moneyline[:odds_home]).to eq odds_home
          end

          it "extracts odds for visiting team/player" do
            odds_visiting = p.convert_odds(224, to: :decimal)
            expect(moneyline[:odds_visiting]).to eq odds_visiting
          end

          it "extracts odds for draw" do
            odds_draw = p.convert_odds(247, to: :decimal)
            expect(moneyline[:odds_draw]).to eq odds_draw
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
        expect(events.count).to eq 176
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
        p.sport_types = ['Soccer', 'Tennis']
        expect(p.sport_types_to_s 'sporttype').to eq "sporttype='Soccer' or sporttype='Tennis'"
      end
    end
    it 'converts odds' do
      expect(p.convert_odds -110, to: :decimal).to eq 1.909
      expect(p.convert_odds 102, to: :decimal).to eq 2.02
      expect(p.convert_odds 1.241, to: :american).to eq -415
      expect(p.convert_odds 4.580, to: :american).to eq 358
    end
  end

end