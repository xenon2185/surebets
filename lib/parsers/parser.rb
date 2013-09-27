require 'nokogiri'

module Parser

  class Parser

    def self.fetch
      xml = get create_url
      parse xml
    end

    def self.sport_types_to_s el_name
      st = sport_types.clone
      first = st.shift
      sport_types_string = ""
      sport_types_string << "#{el_name}='#{first}'"
      st.each do |sport_type|
        sport_types_string << " or #{el_name}='#{sport_type}'"
      end
      sport_types_string
    end

    def self.convert_odds odds, options = {to: :decimal}
      case options[:to]
      when :decimal
        if odds < 0
          (100.0/odds.abs + 1).round 3
        else
          (odds/100.0 + 1).round 3
        end
      when :american
        if odds < 2
          (-100/(odds-1)).round
        else
          ((odds-1)*100).round
        end
      end
    end

    private
      def self.get url
        open(url)
      end


  end

end