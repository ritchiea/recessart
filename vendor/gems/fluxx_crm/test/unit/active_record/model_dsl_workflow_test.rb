require 'test_helper'

class ModelDslWorkflowTest < ActiveSupport::TestCase
  def setup
    @dsl_workflow = ActiveRecord::ModelDslWorkflow.new Race
  end
  
  test 'state and events should both initally be empty' do
    assert @dsl_workflow.states_to_english.empty?
    assert @dsl_workflow.events_to_english.empty?    
  end
  
  test "add state via add_state_to_english" do
    assert_equal Hash.new, @dsl_workflow.states_to_english
    @dsl_workflow.add_state_to_english :a_new_state, 'A New State'
    assert_equal @dsl_workflow.states_to_english[:a_new_state], 'A New State'
  end
  test "add event via add_event_to_english" do
    @dsl_workflow.add_event_to_english :a_new_event, 'A New Event'
    assert_equal @dsl_workflow.events_to_english[:a_new_event], 'A New Event'
  end

  test 'clearing states' do
    @dsl_workflow.add_state_to_english :a_new_state, 'A New State'
    assert !@dsl_workflow.states_to_english.empty?
    @dsl_workflow.clear_states_to_english
    assert @dsl_workflow.states_to_english.empty?
  end
  
  test 'clearing events' do
    @dsl_workflow.add_event_to_english :a_new_event, 'A New Event'
    assert !@dsl_workflow.events_to_english.empty?
    @dsl_workflow.clear_events_to_english
    assert @dsl_workflow.events_to_english.empty?
  end
  
  test 'clearing and adding' do
    workflow = @dsl_workflow
    assert_equal workflow.states_to_english.size, 0
    workflow.clear_states_to_english
    assert workflow.states_to_english.empty?
    workflow.add_state_to_english :a_new_state, 'A New State'
    assert_equal workflow.states_to_english.size, 1
  end
  
  test 'category test new' do
    states = Race.all_states_with_category 'new'
    assert_equal [:new], states
  end

  test 'all_events_with_category' do
    assert_equal [:kick_off], Race.all_events_with_category('fun')
  end

  test 'category test fun' do
    states = Race.all_states_with_category 'fun'
    assert_equal [:beginning], states
  end
  
  test 'all_events test' do
    assert_equal [:kick_off, :sprint, :final_sprint, :reject, :send_back_starting_line], Race.all_events
  end

  test 'all_workflow_states' do
    assert_equal [:new, :beginning, :middle, :final], Race.all_workflow_states
  end
  
  test 'all_rejected_states' do
    assert_equal [:rejected], Race.all_rejected_states
  end
  
  test 'all_new_states' do
    assert_equal [:new], Race.all_new_states
  end

  test 'all_sent_back_states' do
    assert_equal [:sent_back_starting_line], Race.all_sent_back_states
  end

  test 'all_events' do
    assert_equal [:kick_off, :sprint, :final_sprint, :reject, :send_back_starting_line], Race.all_events
  end
  
  test 'all_workflow_events' do
    assert_equal [:kick_off, :sprint, :final_sprint], Race.all_workflow_events
  end
  
  test 'all_rejected_events' do
    assert_equal [:reject], Race.all_rejected_events
  end
  
  test 'all_new_events' do
    assert_equal [], Race.all_new_events
  end
  
  test 'all_sent_back_events' do
    assert_equal [:send_back_starting_line], Race.all_sent_back_events
  end
  
  test 'all_state_categories_with_descriptions ' do
    assert_equal [["Funangry", ["fun", "angry"]], ["New", ["new"]]], Race.all_state_categories_with_descriptions 
  end
  
  test 'event_timeline' do
    race = Race.make
    assert_equal(['new', 'beginning', 'middle', 'final'], race.event_timeline)
  end

  test 'hooking some behaviour when entering a state' do
    @dsl_workflow.add_state_to_english :rejected, '', ['rejected_or_kicked_off', 'some_other_category']
    @dsl_workflow.add_state_to_english :beginning, '', 'rejected_or_kicked_off'

    rejected_or_kicked_off_races = []
    @dsl_workflow.on_enter_state_category('rejected_or_kicked_off', 'here_we_can_pass_some_other_category_too') do |race|
      rejected_or_kicked_off_races << race
    end

    new_race = Race.make
    middle_race = Race.make(:state => 'middle')
    sent_back_race = Race.make(:state => 'final'); sent_back_race.send_back_starting_line; sent_back_race.save!
    rejected_race1 = Race.make(:state => 'rejected'); rejected_race1.state = 'rejected'; rejected_race1.save!
    rejected_race2 = Race.make; rejected_race2.reject; rejected_race2.save!
    kicked_off_race1 = Race.make(:state => 'beginning')
    kicked_off_race2 = Race.make; kicked_off_race2.kick_off; kicked_off_race2.save!

    assert_equal [rejected_race1, rejected_race2, kicked_off_race1, kicked_off_race2].map(&:id).sort, rejected_or_kicked_off_races.map(&:id).sort
  end
end
