class ActionController::ControllerDslShow < ActionController::ControllerDsl
  attr_accessor :audit_template
  attr_accessor :footer_template
  attr_accessor :audit_footer_template
  attr_accessor :mode_template
  attr_accessor :footer_template
  # Send the list of models to the supplied template and do not try to iterate through in the insta index.html.haml file
  attr_accessor :always_skip_wrapper

  def perform_show params, model=nil, fluxx_current_user=nil
    model = if params[:audit_id]
      new_model = model_class.new
      audit = Audit.find params[:audit_id] rescue nil
      if audit
        m2 = YAML::load audit.full_model if audit.full_model
        if m2
          m2.keys.each do |k|
            k2 = "#{k.to_s}="
            new_model.send k2.to_sym, m2[k] rescue nil
          end
          new_model.id = audit.auditable_id
          new_model
        end
      end
    else
      model
    end
    model = model || load_existing_model(params)
    remove_lock(model, fluxx_current_user) if params[:unlock] == '1' && model && fluxx_current_user
    model
  end
  
  def calculate_show_options model, params
    options = {}
    options[:template] = template_map ? template_map.inject(template) {|temp, mapping| params[mapping.first] ? mapping.last : temp} : template
    options[:footer_template] = footer_template
    options[:layout] = layout
    options[:skip_card_footer] = skip_card_footer
    if params[:audit_id]
      # Allows the user to load up a history record
      options[:template] = audit_template if audit_template
      options[:footer_template] = audit_footer_template if audit_footer_template
      options[:full_model] = load_existing_model model.id
    elsif params[:mode]
      # Allows the user to load up an alternate view (mode) based on a hash
      options[:template] = mode_template[params[:mode].to_s] unless mode_template.blank? || mode_template[params[:mode].to_s].blank?
    end
    options
  end
  
  def calculate_error_options params
    if params[:audit_id]
      I18n.t(:insta_no_audit_record_found, :model_id => params[:id])
    else
      I18n.t(:insta_no_record_found, :model_id => params[:id])
    end
  end
end