require 'test_helper'

class GroupTest < ActiveSupport::TestCase
  def setup
  end
  
  test "create a group and grab the members" do
    group = Group.make
    5.times do
      org = Organization.make
      GroupMember.make :groupable => org, :group => group
    end
    
    assert_equal 5, group.group_members.size
  end
end