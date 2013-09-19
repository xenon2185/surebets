class Admin::DashboardController < AdminController
  def index
    PinnacleXmlWorker.perform_async
  end
end
