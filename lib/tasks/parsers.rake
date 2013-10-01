# task :pinnacle => :environment do
#   while true
#     Event.refresh Event.fetch 'Pinnacle'
#     # sleep 60
#     puts "Done Pinnacle"
#     break
#   end
# end

task :'parsers' => :environment do
  while true
    begin
      start = Time.now
      puts "Starting Pinnacle job at #{Time.now}"
      Event.refresh Event.fetch 'Pinnacle'
      puts "Ended Pinnacle job iteration: #{Time.now-start} s"
      sleep 20
      start = Time.now
      puts "Starting Bet-at-home job at #{Time.now}"
      Event.refresh Event.fetch('Bet-at-home')
      puts "Ended Bet-at-home job iteration: #{Time.now-start} s"
      sleep 40
    rescue NoWaitError => e
      sleep e.message.to_i
      puts "Waited #{e.message} seconds"
    end
  end
end