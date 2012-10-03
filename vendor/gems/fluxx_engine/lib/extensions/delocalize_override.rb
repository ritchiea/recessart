module Delocalize
  class LocalizedDateTimeParser
    private
    
    #rectify the fact that this was not allowing dates like 1/2/2011 instead of 01/02/2011
      def self.apply_regex(format)
        # maybe add other options as well
        format.gsub('%B', "(#{Date::MONTHNAMES.compact.join('|')})"). # long month name
          gsub('%b', "(#{Date::ABBR_MONTHNAMES.compact.join('|')})"). # short month name
          gsub('%m', "(\\d{1,2})").                                     # numeric month
          gsub('%A', "(#{Date::DAYNAMES.join('|')})").                # full day name
          gsub('%a', "(#{Date::ABBR_DAYNAMES.join('|')})").           # short day name
          gsub('%Y', "(\\d{2,4})").                                     # long year
          gsub('%y', "(\\d{2,4})").                                     # short year
          gsub('%e', "(\\s?\\d{1,2})").                               # short day
          gsub('%d', "(\\d{1,2})").                                     # full day
          gsub('%H', "(\\d{1,2})").                                     # hour (24)
          gsub('%M', "(\\d{1,2})").                                     # minute
          gsub('%S', "(\\d{1,2})")                                      # second
      end
  end
end