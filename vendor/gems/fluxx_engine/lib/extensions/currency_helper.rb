class CurrencyHelper
  CURRENCY_MAPPER_FROM_SIGN = {
    '$' => {:short_name => 'USD', :long_name => 'Dollar'}
  }
  def self.translate_symbol_to_name currency_symbol
    CURRENCY_MAPPER_FROM_SIGN[currency_symbol]
  end
  def self.translate_symbol_to_long_name currency_symbol
    currency = CURRENCY_MAPPER_FROM_SIGN[currency_symbol]
    currency ? currency[:long_name] : nil
  end
  def self.translate_symbol_to_short_name currency_symbol
    currency = CURRENCY_MAPPER_FROM_SIGN[currency_symbol]
    currency ? currency[:short_name] : nil
  end

  def self.current_symbol
    I18n.t('number.currency.format.unit')
  end
  def self.current_long_name
    translate_symbol_to_long_name(I18n.t('number.currency.format.unit'))
  end
  def self.current_short_name
    translate_symbol_to_long_name(I18n.t('number.currency.format.unit'))
  end
end