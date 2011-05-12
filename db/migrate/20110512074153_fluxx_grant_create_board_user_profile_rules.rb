class FluxxGrantCreateBoardUserProfileRules < ActiveRecord::Migration
  def self.up
    board_profile = UserProfile.where(:name => "Board").first
    board_profile = UserProfile.create(:name => "Board") if !board_profile
    execute "DELETE FROM user_profile_rules WHERE user_profile_id = #{board_profile.id}"
    UserProfileRule.create :user_profile => board_profile, :permission_name => "view" , :model_type => "User"
    UserProfileRule.create :user_profile => board_profile, :permission_name => "view", :model_type => "Organization"
    UserProfileRule.create :user_profile => board_profile, :permission_name => "view", :model_type => "Request"
    UserProfileRule.create :user_profile => board_profile, :permission_name => "view", :model_type => "RequestReport"
    UserProfileRule.create :user_profile => board_profile, :permission_name => "listview", :model_type => "User"
    UserProfileRule.create :user_profile => board_profile, :permission_name => "listview", :model_type => "Organization"
    UserProfileRule.create :user_profile => board_profile, :permission_name => "listview", :model_type => "Request"
    UserProfileRule.create :user_profile => board_profile, :permission_name => "listview", :model_type => "RequestReport"
    UserProfileRule.create :user_profile => board_profile, :permission_name => "listview", :model_type => "ClientStore"
    UserProfileRule.create :user_profile => board_profile, :permission_name => "listview", :model_type => "ClientStore"
    UserProfileRule.create :user_profile => board_profile, :permission_name => "listview", :model_type => "ClientStore"
  end

  def self.down
    board_profile = UserProfile.where(:name => "Board").first
    execute "DELETE FROM user_profile_rules WHERE user_profile_id = #{board_profile.id}"
  end
end