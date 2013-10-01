require 'parsers/pinnacle'

class PinnacleWorker

  include Sidekiq::Worker
  # sidekiq_options queue: :pinnacle, retry: false
  sidekiq_options retry: false

  def perform
    Event.refresh Event.fetch 'Pinnacle'
  end

end