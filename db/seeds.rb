# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# event = { sport_type: 'Soccer', datetime: '2013-08-28 18:44', home: 'Maribor', visiting: 'Viktoria Plzen'}

# bet = { bookmaker: 'Pinnacle', odds_home: 3.75, odds_visiting: 2.07, odds_home: 3.7}

# e = Event.create!(event)

# b = e.bets.build(bet)
# b.save!

# f = File.open('temp/pinnacle.xml')
# doc = Nokogiri.XML(f)
# f.close

# events = doc.xpath("//event[sporttype='Soccer' and descendant::moneyline_home]")

# events.each do |event_node|
#   event = Event.new
#   event.sport_type = event_node.xpath('sporttype').text
#   event.datetime = event_node.xpath('event_datetimeGMT').text
#   event.home = event_node.xpath('descendant::participant[visiting_home_draw="Home"]/participant_name').text
#   event.visiting = event_node.xpath('descendant::participant[visiting_home_draw="Visiting"]/participant_name').text
#   event.save!

#   bet_node = event_node.xpath('descendant::period[period_description="Game"]/moneyline')
#   bet = Bet.new
#   bet.bookmaker = 'Pinnacle'
#   bet.odds_home = bet_node.xpath('moneyline_home').text.to_i
#   bet.odds_visiting = bet_node.xpath('moneyline_visiting').text.to_i
#   bet.odds_draw = bet_node.xpath('moneyline_draw').text.to_i
#   event.bets << bet
# end