require 'parsers/bet_at_home'

class BetAtHomeWorker

  include Sidekiq::Worker
  sidekiq_options queue: :'bet-at-home', retry: false

  def perform
    Parser::BetAtHome.create_dom
    Parser::BetAtHome.parse
  end

end