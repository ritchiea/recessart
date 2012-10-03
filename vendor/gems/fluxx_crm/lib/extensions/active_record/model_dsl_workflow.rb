class ActiveRecord::ModelDslWorkflow < ActiveRecord::ModelDsl
  # A custom SQL query to be executed when the export is run
  attr_accessor :sql_query
  # A mapping from symbol to english word for states
  attr_accessor :states_to_english
  # A mapping from symbol to category
  attr_accessor :states_to_category
  # An ordered list of states
  attr_accessor :ordered_states
  # An ordered list of events
  attr_accessor :ordered_events
  # A mapping from symbol to english word for events
  attr_accessor :events_to_english
  # A list of events to skip validating on when changing state
  attr_accessor :non_validating_events
  # If this is true, the workflow updates will not execute
  attr_accessor :workflow_disabled
  # Alternate workflow model block returns the ID of a different related 
  attr_accessor :alternate_note_model_block

  def initialize model_class
    super model_class
    self.states_to_english = HashWithIndifferentAccess.new
    self.states_to_category = HashWithIndifferentAccess.new
    self.events_to_english = HashWithIndifferentAccess.new
    self.ordered_states = []
    self.ordered_events = []
    self.non_validating_events = []
  end
  
  def prepare_model model
    # placeholder for adding workflow-related methods
  end
  
  # Note that this can be overridden to swap in different state machine systems
  def fire_event model, event_name, user
    unless model.respond_to?(:fire_event_override) && (override_fire_response = model.fire_event_override(event_name, user))
      actually_fire_event model, event_name, user
    else
      override_fire_response
    end
  end

  def actually_fire_event model, event_name, user
    model.send(event_name)
  end
  
  def event_timeline model
    model.running_timeline = true
    old_state = model.state
    model.state = all_new_states(model.class).first
    cycle_count = 0
    timeline = model.class.suspended_delta(false)  do
      working_timeline = [model.state.to_s]
      
      while cycle_count < 500 && (cur_event = (aasm_events_for_state_with_guard(model) & (model.class.all_workflow_events)).last)
        model.send cur_event
        working_timeline << model.state
        cycle_count += 1
      end
      working_timeline
    end || []
    model.state = old_state
    model.running_timeline = false
    timeline
  end
  
  def aasm_events_for_state_with_guard model
    events = model.class.aasm_events.values.select {|event| event.transitions_from_state_with_guard?(model, model.state) }
    events.map {|event| event.name}
  end
  
  # Note that this can be overridden to swap in different functionality to determine the allowed events
  def current_allowed_events model, possible_events
    return [] if model.state.blank?
    
    all_events = aasm_events_for_state_with_guard(model)
    
    permitted_events = if possible_events
      all_events & possible_events
    else
      all_events
    end || []
    
    permitted_events.map do |event_name|
      [event_name, model.class.event_to_english(event_name)]
    end
    
  end
  
  def state_in model, states
    self_state = model.state
    # Note that before the model is created, it may have a blank state; for now consider that to be the initial state
    self_state = model.class.aasm_initial_state if self_state.blank?
    if states.is_a?(Array)
      !states.select{|cur_state| cur_state.to_s == self_state.to_s}.empty?
    else
      states.to_s == self_state
    end
  end
  
  def track_workflow_changes model, force, change_type
    # If state changed, track a WorkflowEvent
    if force || (model.send(:changed_attributes)['state'] != model.state && !((model.send(:changed_attributes)['state']).blank?))
     unless workflow_disabled
        workflowable_hash = if alternate_note_model_block && alternate_note_model_block.is_a?(Proc)
         note_model = alternate_note_model_block.call model
         {:related_workflowable_type => model.class.to_s, :related_workflowable_id => model.id, 
           :workflowable_type => (note_model ? note_model.class.to_s : nil), :workflowable_id => (note_model ? note_model.id : nil)}
       else
         {:workflowable_type => model.class.to_s, :workflowable_id => model.id}
       end
       
        wfe = WorkflowEvent.create workflowable_hash.merge(:comment => model.workflow_note, :change_type => change_type, :ip_address => model.workflow_ip_address.to_s, :old_state => (model.send(:changed_attributes)['state']) || '', :new_state => model.state || '', :created_by => model.updated_by, :updated_by => model.updated_by)
        # p "ESH: creating new wfe=#{wfe.inspect}, errors=#{wfe.errors.inspect}"
        # begin
        #   rails Exception.new 'stack trace'
        # rescue Exception => exception
        #   p "ESH: have an exception #{exception.backtrace.inspect}"
        # end
      end
    end
  end
  
  # TODO ESH: change the below to use metadata added to describe the type of state when calling add_state_to_english for example
  def in_new_state? model
    model.state.to_s =~ /^new/ || model.state.blank?
  end

  def in_draft_state? model
    model.in_state_with_category?("draft")
  end

  def in_reject_state? model
    model.state.to_s =~ /^reject/
  end

  def in_workflow_state? model
    !(model.in_new_state || model.in_reject_state || model.in_sentback_state)
  end

  def in_sentback_state? model
    model.state.to_s =~ /sent_back/ || model.state.to_s =~ /send_back/
  end
  
  def in_state_with_category? model, category
    model.state.nil? ? false : all_states_with_category(model, category).map {|s| s.to_sym}.include?(model.state.to_sym)
  end
  
  def state_to_english model
    state_to_english_from_state_name model.state, model.class
  end
  
  def state_to_english_from_state_name state_name, klass
    if !state_name.blank? && self.states_to_english && self.states_to_english.is_a?(Hash)
      self.states_to_english[state_name.to_sym]
    end || state_name
  end
  
  def event_to_english event_name
    if !event_name.blank? && events_to_english && events_to_english.is_a?(Hash)
      events_to_english[event_name.to_sym]
    end || event_name
  end
  
  def add_state_to_english new_state, state_name, category_names=nil
    self.states_to_english[new_state.to_sym] = state_name
    if category_names
      category_states = self.states_to_category[new_state.to_sym]
      category_states = [] unless category_states
      if category_names.is_a? Array
        category_names.each{|cn| category_states << cn.to_s}
      else
        category_states << category_names.to_s 
      end
      self.states_to_category[new_state.to_sym] = category_states
    end
    ordered_states << new_state
  end

  def add_event_to_english new_event, event_name
    events_to_english[new_event.to_sym] = event_name
    ordered_events << new_event.to_sym
  end

  def add_non_validating_event event
    non_validating_events << event.to_sym
  end
  
  def clear_states_to_english
    self.ordered_states.clear
    self.states_to_category.clear
    self.states_to_english.clear
  end

  def clear_events_to_english
    events_to_english.clear
    ordered_events.clear
  end
  
  def all_events model_class
    ordered_events
  end
  
  def all_states model_class
    ordered_states
  end
  
  def all_states_with_category model_class, category
    if category
      ordered_states.select do |state_name| 
        if state_name
          cur_categories = states_to_category[state_name.to_sym]
          if cur_categories
            !cur_categories.select{|cur_category| cur_category.to_s == category.to_s}.empty?
          end
        end
      end
    end || []
  end

  def all_state_categories_with_descriptions model_class
    states_to_category.values.map do |category|
      [category.to_s.humanize, category]
    end
  end
  
  def is_reject_state? state_name
     state_name.to_s =~ /reject/ || state_name.to_s =~ /cancel/
  end
  def is_new_state? state_name
    initial_state = self.model_class && self.model_class.respond_to?(:aasm_initial_state) ? self.model_class.aasm_initial_state.to_s : nil
    (initial_state && initial_state == state_name.to_s) || state_name.to_s =~ /^new/
  end
  def is_sent_back_state? state_name
    state_name.to_s =~ /sent_back/
  end
  
  def all_workflow_states model_class
    all_states(self) - all_rejected_states(self) - all_sent_back_states(self)
  end
  
  def all_rejected_states model_class
    ordered_states.select{|st| is_reject_state? st.to_s }
  end

  def all_new_states model_class
    ordered_states.select{|st| is_new_state? st.to_s }
  end

  def all_sent_back_states model_class
    ordered_states.select{|st| is_sent_back_state? st.to_s }
  end
  
  def extract_all_event_types model_class
    (ordered_events.map{|ev| ev.to_sym} & model_class.aasm_events.keys.map{|k| k.to_sym}).map do |event_name|
      event_to_state = model_class.aasm_events[event_name].instance_variable_get('@transitions').first.instance_variable_get '@to' rescue nil
      [event_name, event_to_state]
    end
  end

  def all_events model_class
    extract_all_event_types(model_class).map{|pair| pair.first}
  end
  
  def all_workflow_events model_class
    all_events = extract_all_event_types(model_class).map{|pair| pair.first}
    all_events - all_rejected_events(model_class) - all_new_events(model_class) - all_sent_back_events(model_class)
  end

  def all_rejected_events model_class
    extract_all_event_types(model_class).select{|pair| is_reject_state?(pair[1]) if pair.is_a?(Array) && pair[1]}.map{|pair| pair.first}
  end
  
  def all_new_events model_class
    extract_all_event_types(model_class).select{|pair| is_new_state?(pair[1]) if pair.is_a?(Array) && pair[1]}.map{|pair| pair.first}
  end

  def all_sent_back_events model_class
    extract_all_event_types(model_class).select{|pair| is_sent_back_state?(pair[1]) if pair.is_a?(Array) && pair[1]}.map{|pair| pair.first}
  end
  
  def all_events_with_category model_class, category_name
    category_states = all_states_with_category model_class, category_name
    extract_all_event_types(model_class).select{|pair| category_states.include?(pair[1]) if pair.is_a?(Array) && pair[1]}.map{|pair| pair.first}
  end

  def states_for_category(state_category_name)
    cat_states = []
    self.states_to_category.each do |state,cats|
      cat_states << state if cats.include?(state_category_name.to_s)
    end
    cat_states
  end

  def on_enter_state_category(*state_category_names, &on_enter_behaviour)
    cat_states = []
    state_category_names.each do |state_category_name|
      cat_states += states_for_category(state_category_name)
    end

    self.model_class.after_save do
      on_enter_behaviour.call(self) if state_changed? && cat_states.include?(state)
    end
  end
end


# Make it so that we check the guard method before advising that we can transition with this state for this model
class AASM::SupportingClasses::Event
  def transitions_from_state_with_guard?(model, state_name)
    if state_name
      state = state_name.to_sym
      @transitions.any? { |t| t.from == state && t.perform(model) }
    end
  end
end

class AASM::SupportingClasses::StateTransition
  def perform(obj)
    case @guard
      when Symbol, String
        obj.send(@guard)
      when Proc
        @guard.call(obj)
      else
        true
    end
  end
end
