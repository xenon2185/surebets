require 'open-uri'
require 'parsers/pinnacle'

class PinnacleXmlWorker

  include Sidekiq::Worker
  sidekiq_options queue: :pinnacle, retry: false

  def perform
    Parser::Pinnacle.wait
  end

end