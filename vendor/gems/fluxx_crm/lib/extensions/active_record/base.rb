class ActiveRecord::Base
  @@all_workflow_classnames= []
  
  def self.insta_favorite
    has_many :favorites, :as => :favorable
    define_method :is_favorite_for? do |user|
      Favorite.find :first, :conditions => {:user_id => user.id, :favorable_type => self.class.name, :favorable_id => self.id}
    end
    
    define_method :favorite_user_ids do
      favorites.map{|fav| fav.user_id}.flatten.compact
    end
    
  end
  
  
  def self.insta_role
    if respond_to?(:role_object) && role_object
      yield role_object if block_given?
    else
      local_role_object = ActiveRecord::ModelDslRole.new( self )
      class_inheritable_reader :role_object
      write_inheritable_attribute :role_object, local_role_object
      yield local_role_object if block_given?
      
      define_method :extract_related_model do 
        related_object_model = if role_object.extract_related_object_proc
          role_object.extract_related_object_proc.call self
        else
          self
        end
      end
      
      define_method :event_allowed? do |events, user|
        events = [events] unless events.is_a?(Array)
        related_object_model = extract_related_model self
        role_object.check_if_events_allowed?(user, events, related_object_model)
      end
      
      define_method :actions do |user|
        event_pairs = current_allowed_events    # Find all events
        event_names = event_pairs.map {|event| event.first}
        allowed_event_names = if respond_to? :event_allowed?
          event_allowed?(event_names, user) # Limit them by role
        else
          event_names
        end || []
        allowed_event_names && event_pairs.select{|event_pair| allowed_event_names.include?(event_pair.first)}
      end
      
      define_method :admin_edit_allowed_for_user? do |user|
        related_object_model = extract_related_model self
        role_object.admin_edit_allowed_for_user?(user, related_object_model)
      end
    end
  end
  
  
  def self.insta_workflow
    if respond_to?(:workflow_object) && workflow_object
      yield workflow_object if block_given?
    else
      @@all_workflow_classnames << self.name
      local_workflow_object = ActiveRecord::ModelDslWorkflow.new(self)
      class_inheritable_reader :workflow_object
      write_inheritable_attribute :workflow_object, local_workflow_object
      yield local_workflow_object if block_given?
      
      self.send :attr_accessor, :promotion_event
      self.send :attr_accessor, :running_timeline
      
      local_workflow_object.prepare_model self
      
      def update_attribute_without_log_with_specific key, value
        if self.class.respond_to?(:without_workflow)
          self.class.without_workflow do
            update_attribute_without_log_without_specific key, value
          end
        else
          update_attribute_without_log_without_specific key, value
        end
      end
      alias_method_chain :update_attribute_without_log, :specific
      
      def update_attributes_without_log_with_specific attr_map
        if self.class.respond_to?(:without_workflow)
          self.class.without_workflow do
            update_attributes_without_log_without_specific attr_map
          end
        else
          update_attributes_without_log_without_specific attr_map
        end
      end
      alias_method_chain :update_attributes_without_log, :specific
      

      self.instance_eval do
        attr_accessor :workflow_note
        attr_accessor :workflow_ip_address
        before_create :track_workflow_create
        before_update :track_workflow_update
        before_destroy :track_workflow_destroy
        before_save :generate_docs
        
        def without_workflow(&block)
          workflow_was_disabled = workflow_object.workflow_disabled
          workflow_object.workflow_disabled = true
          block.call.tap { workflow_object.workflow_disabled = false unless workflow_was_disabled }
        end
        
        def event_to_english event_name
          workflow_object.event_to_english event_name
        end
        
        def state_to_english_translation state_name
          workflow_object.state_to_english_from_state_name state_name, self
        end
        
        def all_states_with_category category
          workflow_object.all_states_with_category self, category
        end
        
        def all_states
          workflow_object.all_states self
        end
        
        def all_workflow_states
          workflow_object.all_workflow_states self
        end

        def all_rejected_states
          workflow_object.all_rejected_states self
        end
        
        def all_new_states
          workflow_object.all_new_states self
        end

        def all_sent_back_states
          workflow_object.all_sent_back_states self
        end
        
        def all_events
          workflow_object.all_events self
        end
        
        def all_workflow_events
          workflow_object.all_workflow_events self
        end

        def all_rejected_events
          workflow_object.all_rejected_events self
        end
        
        def all_new_events
          workflow_object.all_new_events self
        end

        def all_sent_back_events
          workflow_object.all_sent_back_events self
        end
        
        def all_events_with_category category
          workflow_object.all_events_with_category self, category
        end
        
        def all_state_categories_with_descriptions 
          workflow_object.all_state_categories_with_descriptions self
        end
      end
      
      define_method :insta_fire_event do |event_name, user|
        local_workflow_object.fire_event self, event_name, user
      end
      
      define_method :is_non_validating_event? do |event_name|
        local_workflow_object.non_validating_events.include? event_name.to_sym
      end
      
      define_method :state_in do |states|
        local_workflow_object.state_in self, states
      end

      define_method :in_new_state? do
        local_workflow_object.in_new_state? self
      end

      define_method :in_draft_state? do
        local_workflow_object.in_draft_state? self
      end

      define_method :in_reject_state? do
        local_workflow_object.in_reject_state? self
      end

      define_method :in_workflow_state? do
        local_workflow_object.in_workflow_state? self
      end

      define_method :in_sentback_state? do
        local_workflow_object.in_sentback_state? self
      end

      define_method :in_state_with_category? do |category|
        local_workflow_object.in_state_with_category? self, category
      end

      define_method :track_workflow_create do
        track_workflow_changes false, 'create'
      end
      define_method :track_workflow_update do
        track_workflow_changes false, 'update'
      end
      define_method :track_workflow_destroy do
        track_workflow_changes true, 'destroy'
      end
    
      define_method :track_workflow_changes do |force, change_type|
        local_workflow_object.track_workflow_changes self, force, change_type
      end
    
      define_method :state_to_english do
        local_workflow_object.state_to_english self
      end
    
      define_method :event_to_english do |event_name|
        local_workflow_object.event_to_english event_name
      end
    
      # Allow a parameter possible_events which is an array of legal event names that are being looked for
      define_method :current_allowed_events do |*optional|
        possible_events, *ignored = *optional
        local_workflow_object.current_allowed_events self, possible_events
      end
      
      # Find out all the states a request of this type can pass through from the time it is new doing normal promotion
      define_method :event_timeline do
        local_workflow_object.event_timeline self
      end
      
      define_method :states_passed_through do
        old_states = (WorkflowEvent.select('group_concat(old_state) old_states').where(['workflowable_id = ? and old_state is not null and workflowable_type in (?)', self.id, self.class.extract_own_class_names]).first).old_states
        ((old_states.blank? ? [] : old_states.split(',')) + [self.state]).compact.uniq
      end
      
      define_method :generate_docs do
        if changed_attributes.include?('state') && self.respond_to?(:model_documents)
          ModelDocumentTemplate.where(:model_type => self.class.name, :generate_state => state).all.each do |template|
            next if model_documents.map(&:model_document_template_id).include?(template.id) # skip if already exists
            model_documents.build(:document_type => :text, :document_text => template.document, :model_document_template_id => template.id, :document_file_name => template.description) if template
          end
        end
      end
      
    end
  end

  def self.all_workflow_classnames
    @@all_workflow_classnames.sort
  end
  
  def state_past state_array, marker_state, current_state
    state_array = state_array.map{|elem| elem.to_s}
    marker_state = marker_state.to_s
    current_state = current_state.to_s
    cur_state_index = state_array.index(current_state) || -1
    marker_state_index = state_array.index(marker_state) || -1
    cur_state_index > marker_state_index if cur_state_index && marker_state_index
  end
  
  def state_past_or_equal state_array, marker_state, current_state
    state_array = state_array.map{|elem| elem.to_s}
    marker_state = marker_state.to_s
    current_state = current_state.to_s
    cur_state_index = state_array.index(current_state) || -1
    marker_state_index = state_array.index(marker_state) || -1
    cur_state_index >= marker_state_index if cur_state_index && marker_state_index
  end

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    User.suspended_delta(false) do
      User.without_realtime do
        User.without_auditing do
          if defined?(@current_user)
            @current_user
          else
            @current_user = current_user_session && current_user_session.user
          end
        end
      end
    end
  end

end
