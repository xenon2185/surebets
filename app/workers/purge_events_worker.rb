class PurgeEventsWorker

  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform
    Event.find_each do |event|
      if event.datetime < Time.zone.now - 2.hours
        event.destroy
        puts "Event #{event.id} destroyed"
      end
    end
  end

end