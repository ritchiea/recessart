# Formtastic::SemanticFormBuilder.fieldset_legend_as = :h2

module Formtastic #:nodoc:

  class SemanticFormBuilder < ActionView::Helpers::FormBuilder

    self.inline_order = [ :input, :aft, :hints, :errors ]    
    
    include ActionView::Helpers::JavaScriptHelper
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::FormTagHelper
    include ActionView::Helpers::AssetTagHelper    
    
    # Generates HTML content after for the given method using the HTML supplied in :aft
    #
    def inline_aft_for(method, options) #:nodoc:
      template.content_tag(:div, Formtastic::Util.html_safe(options[:aft]), :class => 'inline-aft')
    end

    def find_collection_for_column_with_multi(column, options)
      if (@object.class.respond_to?(:multi_element_names) && @object.class.multi_element_names && @object.class.multi_element_names.include?(column.to_s))
        unless options[:collection]
          options[:collection] = MultiElementGroup.find_values @object, column.to_s
        end
      elsif   (@object.class.respond_to?(:single_multi_element_names) && @object.class.single_multi_element_names && @object.class.single_multi_element_names.include?(column.to_s))
        unless options[:collection]
          options[:collection] = MultiElementGroup.find_values @object, column.to_s
        end
      end
      find_collection_for_column_without_multi column, options
    end
    alias_method_chain :find_collection_for_column, :multi
    
    def retrieve_value(obj, method) 
      @object ? @object.send(method) : nil
    end
    
    def default_input_type_with_override(method, options = {}) #:nodoc:
      column = self.column_for(method)
      if column && column.type == :decimal && column.name =~ /amount/i
        :amount
      else
        default_input_type_without_override method, options
      end
    end
    alias_method_chain :default_input_type, :override

    def amount_input(method, options)
      amount = ActionView::Helpers::InstanceTag.value(@object, method)
      amount = amount.to_currency if amount.is_a?(BigDecimal)
      html_options = options.delete(:input_html) || {}
      html_options[:value] = amount if amount
      html_options = default_string_options(method, self.class).merge(html_options)
      label("#{method}:", :label => options[:label]) + text_field(method, html_options)
    end
    
    def date_or_datetime_input(method, options)
      date_time = ActionView::Helpers::InstanceTag.value(@object, method) 
      formatted_date_time = if date_time
        if date_time.is_a? Time
          date_time.mdy
        else
          date_time
        end
      else
        nil
      end
      options[:value] = formatted_date_time if formatted_date_time
      label = options.delete(:label)

      label("#{method}:", :label => label) + text_field(method, options)
    end
    
    # Pass in autocomplete_url as the URL that should be invoked to load the results
    # Pass in :related_attribute_name in the options for the form.input to specify the attribute on the related object that should be called
    # So if a user_organization has an attribute organization that should be autocompleted, you want to display the organization's name.  
    # So the syntax would be:
    # = form.input :organization, :label => "Organization", :as => :autocomplete, :autocomplete_url => organizations_path(:format => :json), :related_attribute_name => :name
    def autocomplete_input(method, options)
      related_attribute_name = options[:related_attribute_name] || 'name'
      value_name = derive_autocomplete_value method, related_attribute_name
      
      input_name = generate_association_input_name(method)
      sibling_id = generate_random_id
      label("#{method}:", :label => options[:label]) + 
        text_field_tag(method, nil, (options[:input_html] || {}).merge({"data-sibling".to_sym => sibling_id.to_s, "data-autocomplete".to_sym => options[:autocomplete_url], :value => value_name})) + 
        hidden_field(input_name, {"data-sibling".to_sym => sibling_id.to_s, :class => options[:hidden_attribute_class]})
    end
    
    def derive_autocomplete_value method, related_attribute_name
      related_object = @object.send method if @object.respond_to?(method)
      value_name = if related_object && related_object.respond_to?(related_attribute_name.to_sym)
        related_object.send related_attribute_name
      end || related_object
      value_name
    end
    
    def generate_random_id
      (rand * 999999999).to_i
    end
    
  end
end
