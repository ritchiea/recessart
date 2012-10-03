class Race < ActiveRecord::Base
  belongs_to :updated_by, :class_name => 'User', :foreign_key => 'updated_by_id'

  insta_workflow do |insta|
    insta.add_state_to_english :new, 'New', 'new'
    insta.add_state_to_english :beginning, 'Beginning', ['fun', 'angry']
    insta.add_state_to_english :middle, 'Middle'
    insta.add_state_to_english :final, 'Final'
    insta.add_state_to_english :rejected, 'Reject'
    insta.add_state_to_english :sent_back_starting_line, 'Sent Back to Starting Line'

    insta.add_event_to_english :kick_off, 'Kick Off'
    insta.add_event_to_english :sprint, 'Sprint'
    insta.add_event_to_english :final_sprint, 'Final Sprint'
    insta.add_event_to_english :reject, 'Reject'
    insta.add_event_to_english :send_back_starting_line, 'Send Back to Starting Line'
    
    insta.add_non_validating_event :reject
  end
  insta_search
  
  include AASM

  aasm_column :state
  aasm_initial_state :new
  
  aasm_state :new
  aasm_state :rejected
  aasm_state :beginning
  aasm_state :middle
  aasm_state :final
  aasm_state :sent_back_starting_line
  
  aasm_event :reject do
    transitions :from => [:new, :beginning, :middle, :final], :to => :rejected
  end
  
  aasm_event :kick_off do
    transitions :from => :new, :to => :beginning
  end

  aasm_event :sprint do
    transitions :from => :beginning, :to => :middle
  end

  aasm_event :send_back_starting_line do
    transitions :from => [:middle, :final], :to => :sent_back_starting_line
  end

  aasm_event :final_sprint do
    transitions :from => :middle, :to => :final
  end
end
