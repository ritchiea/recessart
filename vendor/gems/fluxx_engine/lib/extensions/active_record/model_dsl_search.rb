class ActiveRecord::ModelDslSearch < ActiveRecord::ModelDsl
  # Filter fields are used to specify the names of fields which may be used for filtering
  attr_accessor :filter_fields
  # Derived filters allow you to specify a hash of blocks indexed by the filter names.  For each block the parameters search_with_attributes, val are passed in.  
  #  search_with_attributes is a Hash that adds in conditions to the query.  val contains the posted filter value.
  attr_accessor :derived_filters

  def safe_find model_id, local_model_class, force_load=false
    condition = ['id = ?', model_id]
    condition = ['id = ? AND deleted_at IS NULL', model_id] if !really_delete && !force_load
    local_model_class.find :first, :conditions => condition
  end
  
  def safe_delete model, fluxx_current_user=nil
    if model.respond_to?(:updated_by_id) && fluxx_current_user
      model.updated_by_id = fluxx_current_user.id
    end
    unless really_delete
      model.deleted_at = Time.now
      model.save(:validate => false)
    else
      model.destroy
    end
    
    model
  end
  
  # Override if you need to add extra sphinx conditions
  def extra_sphinx_conditions
    nil
  end
  
  # Override if you need to add extra sql conditions
  def extra_sql_conditions
    nil
  end
  

  def model_search q_search, request_params, results_per_page=25, options={}
    #p "ESH: in model_search q_search=#{q_search.inspect}, request_params=#{request_params.inspect}"
    local_model_class = options[:actual_model_class] || model_class
    if !(request_params[:force_sql]) && local_model_class.respond_to?(:sphinx_indexes) && local_model_class.sphinx_indexes
      sphinx_model_search q_search, request_params, results_per_page, options
    else
      sql_model_search q_search, request_params, results_per_page, options
    end
  end

  def sql_model_search q_search, request_params, results_per_page=25, options={}
    #p "ESH: in sql_model_search q_search=#{q_search.inspect}, request_params=#{request_params.inspect}"
    request_params = HashWithIndifferentAccess.new(request_params)
    local_model_class = options[:actual_model_class] || model_class
    local_model_request_params = request_params[local_model_class.calculate_form_name] || {}
    model_request_params = request_params[model_class.calculate_form_name] || {}
    string_fields = local_model_class.columns.select {|col| col.type == :string}.map &:name
    queries = q_search.split ' '
    queries = queries.reject {|q| q.blank?}
    sql_conditions = string_fields.map {|field| queries.map {|q| local_model_class.send :sanitize_sql, ["#{local_model_class.table_name}.#{field} like ?", "%#{q}%"]} }.flatten.compact.join ' OR '
    sql_conditions = "(#{sql_conditions})" unless sql_conditions.blank?
    sql_conditions += " #{sql_conditions.blank? ? '' : ' AND '} deleted_at IS NULL " unless really_delete
    if options[:with]
      logger.info "Note that sql_model_search does not currently support :with"
    end
    
    # Make sure that we search for id
    ([:id] + (filter_fields || [])).each do |attr_pair|
      attr, attr_table = attr_pair
      unless grab_param(attr, local_model_request_params, model_request_params, request_params).blank?
        attr_sql = local_model_class.send :sanitize_sql, [" #{attr_table || local_model_class.table_name}.#{attr} in (?) ", grab_param(attr, local_model_request_params, model_request_params, request_params)]
        sql_conditions += " #{sql_conditions.blank? ? '' : ' AND '}  #{attr_sql}" 
      end
    end

    sort_attr = grab_param(:sort_attribute, local_model_request_params, model_request_params, request_params)
    sort_attr = sort_attr.first if sort_attr.is_a?(Array)
    sort_order = grab_param(:sort_order, local_model_request_params, model_request_params, request_params)
    sort_order = sort_order.first if sort_order.is_a?(Array)
    order_clause = if !sort_attr.blank? && !sort_order.blank?
      "#{sort_attr} #{sort_order}"
    else
      options[:order_clause]
    end
    page_clause = grab_param(:page, local_model_request_params, model_request_params, request_params)
    
    modified_search_conditions = if options[:search_conditions] && options[:search_conditions].is_a?(Hash)
      options[:search_conditions].keys.map do |key| 
        if options[:search_conditions][key]
          "#{key} = '#{options[:search_conditions][key]}'"
        else
          "#{key} IS NULL"
        end
      end.join ' AND '
    else
      options[:search_conditions]
    end

    # Grab a list of models with just the ID, then swap out the list of models with a list of the IDs
    # TODO ESH: should upgrade to arel syntax
   Fluxx.logger.info "searching for #{local_model_class.name}, sql_conditions='#{sql_conditions}', search_conditions=#{modified_search_conditions}, page=#{page_clause}, per_page=#{results_per_page}, :order=#{order_clause}"
    
    models = local_model_class.paginate :select => "#{local_model_class.table_name}.id", 
      :conditions => "#{sql_conditions} #{(!sql_conditions.blank? && !modified_search_conditions.blank?) ? " AND " : ''} #{modified_search_conditions} 
        #{((!sql_conditions.blank? || !modified_search_conditions.blank?) && !extra_sql_conditions.blank?) ? " AND " : ''} #{extra_sql_conditions }", 
      :page => page_clause, :per_page => results_per_page, 
      :order => order_clause, :include => options[:include_relation],
      :joins => options[:joins]
    models.replace models.map(&:id)
    models
  end
  
  # check for an attribute in the params based on the current model object's class name, then the superclass if any from which the search attributes were specified, then just the attribute names
  def grab_param attr_name, local_model_request_params={}, model_request_params={}, request_params={}
    # p "ESH: searching for attr_name=#{attr_name} in local_model_request_params=#{local_model_request_params.inspect}, model_request_params=#{model_request_params.inspect}, request_params=#{request_params.inspect}"
    ret = local_model_request_params[attr_name.to_s] || model_request_params[attr_name.to_s] || request_params[attr_name.to_s]
    # p "ESH: grab_param, found ret=#{ret.inspect} for attr_name=#{attr_name}"
    ret
  end

  def sphinx_model_search q_search, request_params, results_per_page=25, options={}
    #p "ESH: in sphinx_model_search q_search=#{q_search.inspect}, request_params=#{request_params.inspect}"
    local_model_class = options[:actual_model_class] || model_class
    local_model_request_params = request_params[local_model_class.calculate_form_name] || {}
    model_request_params = request_params[model_class.calculate_form_name] || {}
    search_with_attributes = if options[:search_conditions]
      options[:search_conditions].clone 
    end || {}
    
    search_with_attributes.keys.each do |k|
      search_with_attributes[k] = search_with_attributes[k].to_s.to_crc32 unless search_with_attributes[k].to_s.is_numeric?
    end

    search_with_attributes[:deleted_at] = 0 unless really_delete

    # Make sure that we search for id
    ([:id] + (filter_fields || [])).each do |attr_pair|
      attr, attr_table = attr_pair
      unless grab_param(attr, local_model_request_params, model_request_params, request_params).blank?
        if derived_filters && derived_filters[attr] # some attributes have filtering methods; if so call it
          derived_filters[attr].call(search_with_attributes, request_params, attr, grab_param(attr, local_model_request_params, model_request_params, request_params)) # Send the raw un-split value
        elsif grab_param(attr, local_model_request_params, model_request_params, request_params).select{|split_param| !split_param.to_s.is_numeric?}.size > 0 # Check to see if any params are NOT numeric
          # Sphinx doesn't allow string attributes, so if we get a non-numeric value, search for the crc32 hash of it
          values = grab_param(attr, local_model_request_params, model_request_params, request_params).map{|val|val.to_s.to_crc32}
          search_with_attributes[attr] = values
        else
          search_with_attributes[attr] = grab_param(attr, local_model_request_params, model_request_params, request_params).map{|val| val.to_i}
        end
      end
    end
    search_with_attributes[:sphinx_internal_id] = search_with_attributes.delete(:id) if search_with_attributes[:id]
    
    with_clause = (search_with_attributes || {})
    sort_attr = grab_param(:sort_attribute, local_model_request_params, model_request_params, request_params)
    sort_attr = sort_attr.first if sort_attr.is_a?(Array)
    sort_order = grab_param(:sort_order, local_model_request_params, model_request_params, request_params)
    sort_order = sort_order.first if sort_order.is_a?(Array)
    order_clause = if !sort_attr.blank? && !sort_order.blank?
      "#{sort_attr} #{sort_order}"
    else
      options[:order_clause]
    end
    page_clause = grab_param(:page, local_model_request_params, model_request_params, request_params)

    Fluxx.logger.info "searching for #{local_model_class.name}, '#{q_search}', with_clause = #{with_clause.merge(options[:with] || {}).merge(extra_sphinx_conditions || {}).inspect}, order_clause=#{order_clause.inspect}, page=#{page_clause}, per_page=#{results_per_page}"
    model_ids = local_model_class.search_for_ids(
      q_search, :with => with_clause.merge(options[:with] || {}).merge(extra_sphinx_conditions || {}),
      :order => order_clause, :page => page_clause, 
      :per_page => results_per_page, :include => options[:include_relation])
    if model_ids.empty? && !page_clause.blank?
      # Could be we are loading a card listing with pagination that used to work, but now has fewer elements in it, so we should fall back to display the first page
      model_ids = local_model_class.search_for_ids(
        q_search, :with => with_clause,
        :order => order_clause,
        :per_page => results_per_page, :include => options[:include_relation])
    end
    model_ids
  end
end
