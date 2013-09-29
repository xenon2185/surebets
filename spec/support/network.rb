# Override network access and return sample data
def stub_pinnacle_xml
  xml = Factory.xml_feed 'Pinnacle', extracted: true
  Parser::Pinnacle.stub(:get).and_return(xml)
end

def stub_bet_at_home_xml
  xml = Factory.xml_feed 'Bet-at-home', extracted: true
  Parser::BetAtHome.stub(:get).and_return(xml)
end