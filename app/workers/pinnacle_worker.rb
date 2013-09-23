require 'parsers/pinnacle'

class PinnacleWorker

  include Sidekiq::Worker
  sidekiq_options queue: :pinnacle, retry: false

  def perform
    Parser::Pinnacle.create_dom
    Parser::Pinnacle.parse
  end

end