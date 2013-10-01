class Admin::DashboardController < AdminController
  def index
    # Event.refresh Event.fetch 'Pinnacle'
    # Event.refresh Event.fetch 'Bet-at-home'
    # PurgeEventsWorker.perform_async
  end
end
