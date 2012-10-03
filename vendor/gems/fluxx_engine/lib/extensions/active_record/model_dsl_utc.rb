class ActiveRecord::ModelDslUtc < ActiveRecord::ModelDsl
  # List of attributes that should use UTC
  attr_accessor :time_attributes

  # Truncate the hours/min/seconds and store UTC time.  Also retrieve UTC time bereft of hours/minutes/second
  def add_utc_time_attributes
    if time_attributes
      time_attributes.each do |name|
        model_class.send :define_method, name do
          value = read_attribute(name.to_sym)
          value.utc if value rescue nil
        end

        model_class.send :define_method, "#{name}=" do |date|
          begin
            date = if date.is_a?(String) && !(date.blank?)
              found_date = Time.parse_localized(date) rescue nil
              found_date = Time.parse(date) unless found_date && found_date.is_a?(Time)
#              p "--------------------------------------------------------------------------------"
#              p "#{name} ====== #{date} ------ #{found_date}"
              found_date
            else
              date
            end
            if date && (date.is_a?(Time) || date.is_a?(Date))
              write_attribute(name.to_sym, Time.utc(date.year,date.month,date.day,0,0,0))
            else
              write_attribute(name.to_sym, nil)
            end
          rescue ArgumentError => e
            # Errors need to be added at validation time; so we save them in an array for later use
            self.add_utc_time_validate_error name, I18n.t(:bad_date_format, :date_string => date)
          end
        end
      end

      model_class.send :define_method, :add_utc_time_validate_error do |name, error|
        @utc_time_validate_errors = [] unless @utc_time_validate_errors
        @utc_time_validate_errors << [name, error]
      end

      model_class.send :define_method, :validate_utc_time do
        if @utc_time_validate_errors
          @utc_time_validate_errors.each do |error_array|
            name, error = error_array
            self.errors.add name, error
          end
        end
      end
      
      model_class.send :validate, :validate_utc_time
    end
  end
  
end