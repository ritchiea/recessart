# TODO - remove all the star_ formats - no longer necessary
Time::DATE_FORMATS[:date_time_seconds] = "%m/%d/%Y %H:%M:%S"
Time::DATE_FORMATS[:date_time] = "%m/%d/%Y %H:%M"
Time::DATE_FORMATS[:time] = "%B %Y"
Time::DATE_FORMATS[:mdy] = "%m/%d/%Y"
Time::DATE_FORMATS[:star_mdy] = "*%m/*%d/%y"
Time::DATE_FORMATS[:star_dmy] = "*%d/*%m/%y"
Time::DATE_FORMATS[:full] = "%B %d, %Y"
Time::DATE_FORMATS[:star_full] = "%B *%d, %Y"
Time::DATE_FORMATS[:star_full_dmy] = "*%d %B %Y"
Time::DATE_FORMATS[:hours_minutes] = "%H:%M"
Time::DATE_FORMATS[:star_hours_minutes] = "*%H:%M"
Time::DATE_FORMATS[:hours_minutes_ampm] = "%I:%M %p"
Time::DATE_FORMATS[:star_hours_minutes_ampm] = "*%I:%M %p"
Time::DATE_FORMATS[:msoft] = "%Y-%m-%dT%H:%M:%S.000"
Time::DATE_FORMATS[:sql] = "%Y-%m-%d"
Time::DATE_FORMATS[:hgrant] = "%Y%m%dT%H:%M-0000"
Time::DATE_FORMATS[:month_year] = "%B, %Y"
Time::DATE_FORMATS[:abbrev_month_year] = "%b, %Y"
Time::DATE_FORMATS[:iso_date] = "%Y-%m-%d"

def strip_zeros_from_date(marked_date_string)
  marked_date_string.gsub('*0', '').gsub('*', '').gsub(/ 0(\d\D)/, ' \1').gsub(/-0(\d\D)/, '-\1').gsub(/\/0(\d\D)/, '/\1').gsub(/^0(\d\D)/, '\1')
end


module FluxxTimeFormatUtilities
  def abbrev_month_year
    self.to_s(:abbrev_month_year)
  end
  def month_year
    self.to_s(:month_year)
  end
  def msoft
    self.to_s(:msoft)
  end
  
  def hgrant
    self.to_s(:hgrant)
  end
  
  def sql
    self.to_s(:sql)
  end
  
  def ampm_time
    "#{strip_zeros_from_date(self.to_s(:star_hours_minutes_ampm))}"
  end
  def mdy_time
    "#{self.mdy} #{strip_zeros_from_date(self.to_s(:star_hours_minutes))}" 
  end
  def mdy
    fluxx_short
  end
  def dmy
    fluxx_short
  end
  def fluxx_short
    strip_zeros_from_date I18n.l(self, {:format => :fluxx_short}) rescue "%m/%d/%Y"
  end
  def iso_date
    self.to_s(:iso_date)
  end
  
  def full
    fluxx_long
  end
  
  def full_dmy
    fluxx_long
  end
  
  def fluxx_long
    strip_zeros_from_date I18n.l(self, :format => :fluxx_long) rescue "%B %d, %Y"
  end
  
  def date_time_seconds
    self.to_s(:date_time_seconds)
  end
  
  def date_time
    self.to_s(:date_time)
  end
  

  def next_business_day
    skip_weekends 1
  end    

  def previous_business_day
    skip_weekends -1
  end

  def skip_weekends inc
    date = self
    date += inc
    while (date.wday % 7 == 0) or (date.wday % 7 == 6) do
      date += inc
    end
    date
  end
  
end


class Time
  include FluxxTimeFormatUtilities
end

class DateTime
  include FluxxTimeFormatUtilities
end


# Key issue - format of entered dates:
# date is displayed like:  31/3/2011
# date is input like:  31-3-2011
# 
# This is works correctly in ruby 1.8 and 1.9
# ruby-1.8.7-p302 > Time.parse '31-3-2011' # => Thu Mar 31 00:00:00 -1000 2011 
# ruby-1.9.2-p0 > Time.parse('31-3-2011')    # => 2011-03-31 00:00:00 -1000 
# 
# Changes in parsing dates for ruby 1.9:
# * no longer has difference in parsing dates with dash or forward slash - they are always in euro format
# 
# potential for wrong dates:
# ruby-1.8.7-p302 > Time.parse('10/1/2011') # => Sat Oct 01 00:00:00 -1000 2011 
# ruby-1.8.7-p302 > Time.parse('10-1-2011') # => Mon Jan 10 00:00:00 -1000 2011 
# ruby-1.9.2-p0 > Time.parse('10/1/2011') # => 2011-01-10 00:00:00 -1000 
# ruby-1.9.2-p0 > Time.parse('10-1-2011') # => 2011-01-10 00:00:00 -1000 
# 
# or rasing exceptions:
# ruby-1.8.7-p302 > Time.parse('3/31/2011') # => Thu Mar 31 00:00:00 -1000 2011 
# ruby-1.9.2-p0 > Time.parse('3/31/2011')
# ArgumentError: argument out of range
#         from /Users/mark/.rvm/rubies/ruby-1.9.2-p0/lib/ruby/1.9.1/time.rb:198:in `local'
#         from /Users/mark/.rvm/rubies/ruby-1.9.2-p0/lib/ruby/1.9.1/time.rb:198:in `make_time'
#         from /Users/mark/.rvm/rubies/ruby-1.9.2-p0/lib/ruby/1.9.1/time.rb:267:in `parse'
#         from (irb):4
#         from /Users/mark/.rvm/rubies/ruby-1.9.2-p0/bin/irb:17:in `<main>'
# 
# and in euro format:
# ruby-1.8.7-p302 > Time.parse '31/3/2011'
# ArgumentError: argument out of range
#         from /Users/mark/.rvm/rubies/ruby-1.8.7-p302/lib/ruby/1.8/time.rb:184:in `local'
#         from /Users/mark/.rvm/rubies/ruby-1.8.7-p302/lib/ruby/1.8/time.rb:184:in `make_time'
#         from /Users/mark/.rvm/rubies/ruby-1.8.7-p302/lib/ruby/1.8/time.rb:243:in `parse'
#         from (irb):60
# ruby-1.9.2-p0 > Time.parse '31/3/2011' # => 2011-03-31 00:00:00 -1000 
# 
# ISO standard format:
# ruby-1.8.7-p302 > Time.parse('2011-3-31') # => Thu Mar 31 00:00:00 -1000 2011 
# ruby-1.9.2-p0 > Time.parse('2011-3-31') # => 2011-03-31 00:00:00 -1000 
# ruby-1.8.7-p302 > Time.parse('2011/3/31') # => Thu Mar 31 00:00:00 -1000 2011 
# ruby-1.9.2-p0 > Time.parse('2011/3/31') # => 2011-03-31 00:00:00 -1000 
# 
# ==
# 
# So if we want to have users input in euro format, i.e. 31/3/2011, and support Ruby 1.9,
# then we need to probably use something like delocalize gem https://github.com/clemens/delocalize
# OR:
# we just use ISO standard (YYYY-MM-DD) for all data entry related to dates, and not worry about it.