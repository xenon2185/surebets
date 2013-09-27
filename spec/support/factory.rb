module Factory

  class << self

    def pinnacle_xml_feed
      File.read File.join('spec','fixtures','pinnacle','201309231021.xml')
    end

    def bet_at_home_xml_feed
      File.read File.join('spec','fixtures','bet_at_home','201309231021.xml')
    end

  end

end