RSpec::Matchers.define :have_bet_from do |expected_string|
  match do |actual|
    raise "No events" if actual.empty?
    actual.each do |event|
      bet_count = event.bets.where(bookmaker: expected_string).count
      case 
      when bet_count > 1
        raise "Multiple bets from #{expected_string} for event\n
              #{event.datetime} #{event.home} #{event.visiting}"
      when bet_count == 0
        raise "No bets from #{expected_string} for event #{event.home} - #{event.visiting}"
      end
    end
    true
  end

  failure_message_for_should do |actual|
    "expected that every event in '#{actual}' would have exactly one bet from '#{expected_string}'"
  end

  description do
    "have one bet for every event from #{expected_string}"
  end

end