module PinnacleFactory

  class << self

    def events
      Parser::Pinnacle.stub(:get)
      Parser::Pinancle.fetch
    end

  end

end