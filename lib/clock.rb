require File.expand_path('../../config/boot',        __FILE__)
require File.expand_path('../../config/environment', __FILE__)
require 'clockwork'

module Clockwork

  # every 1.minute, 'pinnacle'do
  #   PinnacleWorker.perform_async
  # end

  # every 1.minute, 'bet-at-home' do
  #   BetAtHomeWorker.perform_async
  # end

  every 1.hour, 'purge-events' do
    PurgeEventsWorker.perform_async
  end

end 