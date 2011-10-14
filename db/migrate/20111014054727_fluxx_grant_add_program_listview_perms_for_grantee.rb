class FluxxGrantAddProgramListviewPermsForGrantee < ActiveRecord::Migration
  def self.up
    p = UserProfile.where(:name => "Grantee").first
    if (p)
      UserProfileRule.create :permission_name => "listview", :allowed => 1, :user_profile_id => p.id, :model_type => "Program"
      UserProfileRule.create :permission_name => "listview", :allowed => 1, :user_profile_id => p.id, :model_type => "SubProgram"
      UserProfileRule.create :permission_name => "listview", :allowed => 1, :user_profile_id => p.id, :model_type => "Initiative"
      UserProfileRule.create :permission_name => "listview", :allowed => 1, :user_profile_id => p.id, :model_type => "SubInitiative"
    end
  end

  def self.down

  end
end