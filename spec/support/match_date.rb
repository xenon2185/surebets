RSpec::Matchers.define :match_date do |expected_string|
  match do |actual|
    format_date(actual) == expected_string
  end

  failure_message_for_should do |actual|
    "expected that '#{format_date actual}' would match '#{expected_string}'"
  end

  failure_message_for_should_not do |actual|
    "expected that '#{format_date actual}' would not match '#{expected_string}'"
  end

  description do
    "be a date matching #{expected_string}"
  end

  def format_date date
    # "#{date.year}-#{date.month}-#{date.day}"
    "%d-%02d-%02d %02d:%02d" % [date.year, date.month, date.day, date.hour, date.minute]
  end
end