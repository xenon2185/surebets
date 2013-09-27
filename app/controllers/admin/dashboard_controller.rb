class Admin::DashboardController < AdminController
  def index
    BetAtHomeWorker.perform_async
  end
end
