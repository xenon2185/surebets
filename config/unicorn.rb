# If you have a very small app you may be able to
# increase this, but in general 3 workers seems to
# work best
worker_processes 3

# Immediately restart any workers that
# haven't responded within 30 seconds
timeout 30
# Load your app into the master before forking
# workers for super-fast worker spawn times
preload_app true

before_fork do |server, worker|
   @sidekiq_pid ||= spawn("bundle exec sidekiq -c 1") #2 -q pinnacle -q bet-at-home")
   @clockwork_pid ||= spawn("bundle exec clockwork lib/clock.rb")
   @rake_parsers_pid ||= spawn("bundle exec rake parsers")
end

after_fork do |server, worker|
  Sidekiq.configure_client do |config|
    config.redis = { :size => 1 }
  end
  Sidekiq.configure_server do |config|
    config.redis = { :size => 5 }
  end
end