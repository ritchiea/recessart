module FluxxCrmAlert
  class ComparingWrapper
    include Comparable

    def initialize(value)
      @value = value
    end

    def <=>(other)
      @value <=> Float(other)
    rescue ArgumentError
      @value <=> other
    end

    def ==(other)
      @value == other
    end

    def in(other)
      @value.include?(other)
    end
  end

  extend FluxxModuleHelper

  when_included do
    has_many :alert_recipients, :dependent => :destroy
    has_many :alert_users, :class_name => AlertRecipient.name, :conditions => ["alert_recipients.user_id IS NOT NULL"]
    has_many :recipients, :through => :alert_users, :source => 'user'

    validates :name, :presence => true, :uniqueness => true

    class_inheritable_hash :recipient_roles
    self.recipient_roles = HashWithIndifferentAccess.new
    class_inheritable_hash :matchers
    self.matchers = HashWithIndifferentAccess.new

    after_initialize :on_init
    after_create :save_roles
    after_save :save_roles
    before_validation(:on => :create) do
      self.last_realtime_update_id = RealtimeUpdate.maximum(:id) if self.last_realtime_update_id.nil?
    end

    acts_as_audited({:full_model_enabled => false, :except => [:type, :last_realtime_update_id]})
    insta_search
    insta_lock
    insta_export

    ##################################################
    attr_matcher :report_type, :state
    attr_matcher :name => :lead_user_ids, :attribute => 'request.lead_user_ids', :comparer => 'in'
    attr_matcher :name => :program_id, :attribute => 'request.program_id',
                 :from_params => lambda{|request_report_params| request_report_params[:request_hierarchy].map{|rh| rh.split("-").first}}

    attr_matcher :name => :due_within_days, :attribute => :due_at, :comparer => "due_in"
    attr_matcher :name => :overdue_by_days, :attribute => :due_at, :comparer => "overdue_by"

    attr_recipient_role :program_lead,
                        :recipient_finder => lambda{|request_report| request_report.request.program_lead }

    attr_recipient_role :grantee_org_owner,
                        :recipient_finder => lambda{|request_report| request_report.request.grantee_org_owner },
                        :friendly_name => "Primary contact"

    attr_recipient_role :grantee_signatory,
                        :recipient_finder => lambda{|request_report| request_report.request.grantee_signatory },
                        :friendly_name => "Primary signatory"

    attr_recipient_role :fiscal_org_owner,
                        :recipient_finder => lambda{|request_report| request_report.request.fiscal_org_owner },
                        :friendly_name => "Fiscal organization owner"

    attr_recipient_role :fiscal_signatory,
                        :recipient_finder => lambda{|request_report| request_report.request.program_lead }
  end

  class_methods do
    def board_or_employee_recipients
      User.joins(:user_profile).where("user_profiles.name = 'Employee' OR user_profiles.name = 'Board'").order("users.first_name, users.last_name ASC")
    end

    def attr_matcher(*matcher_opts)
      matcher_opts.each { |opts|
        if opts.is_a?(Hash)
          name, comparer, attribute, from_params = opts.values_at(:name, :comparer, :attribute, :from_params)
        else
          name, comparer, attribute, from_params = opts.to_s, nil, nil
        end

        attribute ||= name
        comparer ||= '=='
        from_params ||= lambda{|model_params| model_params[name]}

        matchers[name.to_sym] = {:comparer => comparer, :attribute => attribute, :from_params => from_params}

        define_method(name) do
          return nil unless filter[name]
          filter[name][:values]
        end

        define_method("#{name}=") do |value|
          if value.blank?
            filter.delete(name)
          else
            #TODO: we no longer need comparer and attribute here as it's in the Alert::matchers hash
            filter[name] = {:values => [value].flatten, :comparer => comparer, :attribute => attribute }
          end
        end
      }
    end

    def attr_recipient_role(name, opts)
      recipient_finder, friendly_name = opts.values_at(:recipient_finder, :friendly_name)

      friendly_name ||= name.to_s.humanize

      self.recipient_roles[name] = {:friendly_name => friendly_name, :recipient_finder => recipient_finder}

      attr_reader name

      define_method("#{name}=") do |value|
        bool_value = if value == "1"
                  true
                elsif value == "0"
                  false
                else
                  !!value
                end

        instance_variable_set("@#{name}", bool_value)
      end
    end

    def time_based_filtered_attrs
      ["due_within_days", "due_in_days", "overdue_by_days"]
    end
    
    def max_alert_results
      1000
    end
    
    def max_time_based_alert_results
      5000
    end
    
    def with_triggered_alerts!(&alert_processing_block)
      Alert.find_each do |alert|
        
        # Find models that match this filter
        model_filter = JSON.parse(alert.filter)
        filter_params=alert.filter_as_hash
        controller = alert.controller_klass.new
        # Add an admin user as the current user for doing the search to bypass the controller perms check
        controller.instance_variable_set '@current_user', User.joins(:user_permissions).where(:user_permissions => {:name => 'admin'}).first || User.first
        matched_models = if alert.has_time_based_filtered_attrs?
          alert.controller_klass.class_index_object.load_results(filter_params, nil, nil, controller, Alert.max_time_based_alert_results)
        else
          rtu_matched_ids = alert.model_ids_matched_through_rtus
          if rtu_matched_ids && !rtu_matched_ids.empty?
            form_name = alert.controller_klass.class_index_object.model_class.calculate_form_name
            model_params = filter_params[form_name] || {}
            model_params['id'] = rtu_matched_ids
            filter_params[form_name] = model_params
            alert.controller_klass.class_index_object.load_results(filter_params, nil, nil, controller, Alert.max_alert_results)
          else
            []
          end
        end

        alert_processing_block.call(alert, matched_models.compact.uniq) unless matched_models.empty?
      end
    end
  end

  instance_methods do
    def controller_klass
      model_controller_type.constantize
    end

    def model_ids_matched_through_rtus
      klass = controller_klass.class_index_object.model_class
      rtus = RealtimeUpdate.where("id > ?", last_realtime_update_id).where(:type_name => klass.extract_class_names_for_model(klass)).order('id asc').all
      update_attribute(:last_realtime_update_id, rtus.last.id) if rtus && !rtus.empty?
      rtus.map{|rtu| rtu.model_id.to_s}
    end
    
    def models_matched_through_rtus
      matching_models = []
      last_rtu_id = self.last_realtime_update_id || -1
      RealtimeUpdate.where("id > ?", last_rtu_id).order('id asc').find_each do |rtu|
        last_rtu_id = rtu.id
        matching_models << rtu.model if should_be_triggered_by_model?(rtu.model)
      end
      update_attribute(:last_realtime_update_id, last_rtu_id)
      matching_models
    end

    def filtered_attrs
      filter_as_hash.values.first.keys
    end

    def filter_as_hash
      return {} unless filter
      
      model_filter = JSON.parse(filter)
      filter_params=model_filter.inject(HashWithIndifferentAccess.new) do |acc, filter_hash|
        unless filter_hash.blank? || filter_hash['name'].blank? || filter_hash['value'].blank?
          name = filter_hash['name']
          value = filter_hash['value']
          # Parse out the class:param_name
          name.gsub('[]', '') =~ /(.*)\[(.*)\]/
          model_key, attr_name = [$1, $2]
          acc[model_key] ||= HashWithIndifferentAccess.new
          acc[model_key][attr_name] = value unless ['sort_order', 'sort_attribute'].include?(attr_name) 
        end
        acc
      end
    end

    def has_time_based_filtered_attrs?
      !(self.class.time_based_filtered_attrs & filtered_attrs).empty?
    end

    def has_rtu_based_filtered_attrs?
      !(filtered_attrs - self.class.time_based_filtered_attrs).empty?
    end

    def should_be_triggered_by_model?(model)
      return false unless model.is_a?(model_type.constantize)

      filter_as_hash.select do |attr, value|
        !self.class.time_based_filtered_attrs.include?(attr)
      end.map do |attr, value|
        model_value = call_method_chain(model, attr)
        [value].flatten.map do |v|
          model_value == value
        end.any?
      end.all?
    end

    def models_matched_through_time_based_matchers
      t = model_type.constantize.arel_table

      due_in_predicates = filter_as_hash.select{ |k,_| k == "due_in_days"}.map do |(k,val)|
        t["due_at"].lteq_any([val].flatten.map{|v| v.to_i.days.from_now})
      end

      overdue_by_predicates = filter_as_hash.select{ |k,_| k == "overdue_by_days"}.map do |(k,val)|
        t["due_at"].lteq_any([val].flatten.map{|v| v.to_i.days.ago})
      end

      predicate = (due_in_predicates + overdue_by_predicates).inject(:or)

      model_type.constantize.where(predicate)
    end

    def call_method_chain(object, method_chain)
      method_chain.to_s.split('.').inject(object){|object, method_name| object.send(method_name)}
    end

    def model_recipients(model)
      alert_recipients.map do |alert_recipient|
        if alert_recipient.user
          alert_recipient.user
        else
          role_recipient_opts = self.class.recipient_roles[alert_recipient.rtu_model_user_method.to_sym]
          role_recipient_opts[:recipient_finder].call(model) if role_recipient_opts
        end
      end.compact.uniq
    end

    def to_liquid
      {}
    end

    def liquid_subject(locals={})
      Liquid::Template.parse(subject).render(locals.stringify_keys.merge('alert' => self))
    end

    def liquid_body(locals={})
      Liquid::Template.parse(body).render(locals.stringify_keys.merge('alert' => self))
    end

    def on_init
      load_roles
    end

    def load_roles
      # Check to see whether the recipient roles have been populated during initialization
      unless roles_already_populated?
        self.class.recipient_roles.keys.each do |recipient_role|
          is_set = self.alert_recipients.where(:rtu_model_user_method => recipient_role).exists?
          send("#{recipient_role}=", is_set)
        end
      end
    end
    
    def roles_already_populated?
      self.class.recipient_roles.keys.any?{|role_name| !send(role_name).nil?}
    end

    def save_roles
      self.class.recipient_roles.keys.each do |recipient_role|
        save_role(recipient_role)
      end
    end

    def save_role(role_name)
      is_a_recipient = send(role_name)
      was_a_recipient = self.alert_recipients.where(:rtu_model_user_method => role_name).exists?

      return if was_a_recipient && is_a_recipient
      return if !was_a_recipient && !is_a_recipient

      if is_a_recipient
        AlertRecipient.where(:alert_id => self.id, :rtu_model_user_method => role_name).create!
      else
        AlertRecipient.where(:alert_id => self.id, :rtu_model_user_method => role_name).each(&:destroy)
      end
    end
  end
end
