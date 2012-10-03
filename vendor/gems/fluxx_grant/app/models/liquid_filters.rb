module LiquidFilters
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TextHelper
  include ApplicationGrantHelper
  
  def format_date(date, format = 'full')
    date.present? ? date.send(format) : nil
  end
  
  # ex: {{ request_transaction.amount_due | currency: 'Rs. ' }}
  def currency(number, unit='$', delimiter=',', precision=0, format='%u%n')
    return '' if number.blank? || number == 0
    number_to_currency(number, :unit => unit, :delimiter => delimiter, :precision => precision, :format => format)
  end
  
  def titlecase(string)
    return nil unless string
    string.titlecase
  end
  
  def capitalize(string)
    return nil unless string
    string.capitalize
  end
  
  def to_english(num)
    return nil unless num
    num.to_english
  end
  
  # provides the ability to assign a value from the result of a filter
  # ex: {{ request.request_reports | sort: 'due_at' | assign_to: 'request_reports' }}
  def assign_to(value, name)
    @context[name] = value ; nil
  end
  
  def to_rtf(string)
    # http://en.wikipedia.org/wiki/Rich_Text_Format#Character_encoding
    # RTF is an 8-bit format. That would limit it to ASCII, but RTF can encode characters beyond ASCII by escape sequences.
    # For a Unicode escape the control word \u is used, followed by a 16-bit signed decimal integer giving the Unicode code point number.
    # ... Until RTF specification version 1.5 release in 1997, RTF has only handled 7-bit characters directly and 8-bit characters encoded as hexadecimal (using \'xx).
    # ... RTF files are usually 7-bit ASCII plain text.
    return nil unless string
    string.gsub!("\n", "\\line\n")
    string.gsub!("\t", "\\tab\t")
    
    # unicode rtf output to covert non-ascii chars: 8-bit to hex, 16-bit to code point
    string.unpack('U*').map { |n| n < 128 ? n.chr : n < 256 ? "\\'#{n.to_s(16)}" : "\\u#{n}\\'3f" }.join('')
  end
  
  def with_line_break(string)
    string.present? ? "#{string}<br/>" : string
  end
  
  def date_add_months(time, number_months=0)
    time + number_months.to_i.months
  end

  def pct(a, b)
    return 0 if b.blank? || b < 1
    "#{(a.to_f / b.to_f * 100).to_i}%"
  end
  
end

Liquid::Template.register_filter(LiquidFilters)