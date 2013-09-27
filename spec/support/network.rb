# Override network access and return sample data
def stub_pinnacle_xml
  xml = Factory.pinnacle_xml_feed
  Parser::Pinnacle.stub(:get).and_return(xml)
end