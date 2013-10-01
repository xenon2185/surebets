require 'parsers/bet_at_home'

class BetAtHomeWorker

  include Sidekiq::Worker
  # sidekiq_options queue: :'bet-at-home', retry: false
  sidekiq_options retry: false

  def perform
    Event.refresh Event.fetch "Bet-at-home"
  end

end