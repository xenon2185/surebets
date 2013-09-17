class PinnacleXmlWorker

  include Sidekiq::Worker
  sidekiq_options queue: :pinnacle, retry: false

  def perform
    sleep 10
  end

end