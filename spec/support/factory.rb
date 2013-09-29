module Factory

  class << self

    def xml_feed bookmaker, options={extracted: false}
      bookmaker = bookmaker.to_s.downcase.gsub('-','_')
      suffix = options[:extracted] ? '_extracted.xml' : '.xml'
      File.read File.join('spec','fixtures',bookmaker,"201309231021#{suffix}")
    end

  end

end