require 'test_helper'

class ModelDslRoleTest < ActiveSupport::TestCase
  def setup
    @model_dsl_role = ActiveRecord::ModelDslRole.new Race
    @related_object = Race.make
    @related_object_class = Race
  end
  
  test "initialize should assign an Hash" do
    assert @model_dsl_role.event_role_mappings.is_a?(Hash)
    assert @model_dsl_role.event_role_mappings.empty?
  end

  test "assign individual event role" do
    @model_dsl_role.add_event_roles :event1, nil, :role1
    assert @model_dsl_role.roles_for_event_and_related_object(:event1, nil)
    @model_dsl_role.add_event_roles :event1, @related_object_class, :role1
    assert @model_dsl_role.roles_for_event_and_related_object(:event1, @related_object_class)
  end

  test "assign some event roles" do
    roles_to_assign = [:role1, :role2]
    @model_dsl_role.add_event_roles :event1, @related_object_class, roles_to_assign
    found_roles = @model_dsl_role.roles_for_event_and_related_object :event1, @related_object_class
    assert_equal roles_to_assign, found_roles
    
    # Multiple copies of the same event/roles should not result in dupes
    @model_dsl_role.add_event_roles :event1, @related_object_class, roles_to_assign
    found_roles = @model_dsl_role.roles_for_event_and_related_object :event1, @related_object_class
    assert_equal roles_to_assign, found_roles

    # A new role should be merged in correctly
    @model_dsl_role.add_event_roles :event1, @related_object_class, (roles_to_assign + [:role3])
    found_roles = @model_dsl_role.roles_for_event_and_related_object :event1, @related_object_class
    assert_equal 3, found_roles.size
  end
  
  test "test clear all" do
    @model_dsl_role.add_event_roles :event1, @related_object_class, [:role1, :role2]
    @model_dsl_role.clear_all_event_roles
    found_roles = @model_dsl_role.roles_for_event_and_related_object :event1, @related_object_class
    assert_equal 0, found_roles.size
  end
  
  test "test clear_event" do
    @model_dsl_role.add_event_roles :event1, @related_object_class, [:role1, :role2]
    @model_dsl_role.add_event_roles :event2, @related_object_class, [:role1, :role2]
    @model_dsl_role.clear_event :event2
    found_roles = @model_dsl_role.roles_for_event_and_related_object :event2, @related_object_class
    assert found_roles.empty?
  end
  
  test "test event_allowed_for_user" do
    @model_dsl_role.add_event_roles :event1, @related_object_class, [:role1, :role2]
    @model_dsl_role.add_event_roles :event2, @related_object_class, [:role2, :role3]
    
    akey = @model_dsl_role.event_role_mappings[:event1].keys.first
    user = User.make
    role = user.has_role! :role1, @related_object
    
    assert @model_dsl_role.event_allowed_for_user?(user, :event1, @related_object)
    assert !@model_dsl_role.event_allowed_for_user?(user, :event2, @related_object)
  end
  
  test "test event_allowed_for_user for admin" do
    @model_dsl_role.add_event_roles :event1, @related_object_class, [:role1, :role2]
    @model_dsl_role.add_event_roles :event2, @related_object_class, [:role2, :role3]
    
    akey = @model_dsl_role.event_role_mappings[:event1].keys.first
    user = User.make
    user.has_permission! :admin
    
    assert @model_dsl_role.event_allowed_for_user?(user, :event1, @related_object)
    assert @model_dsl_role.event_allowed_for_user?(user, :event2, @related_object)
  end
  
  
  test "test that we can store the extract_related_object" do
    @model_dsl_role.extract_related_object do
      # p "ESH: hi there"
    end
    assert @model_dsl_role.extract_related_object_proc
  end
end