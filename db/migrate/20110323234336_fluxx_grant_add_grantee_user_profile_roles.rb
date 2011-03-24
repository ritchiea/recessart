class FluxxGrantAddGranteeUserProfileRoles < ActiveRecord::Migration
  def self.up
    grantee_profile = UserProfile.where(:name => 'Grantee').first
    UserProfileRule.create :user_profile => grantee_profile, :permission_name => 'create_own', :model_type => 'Request'
    UserProfileRule.create :user_profile => grantee_profile, :permission_name => 'view_own', :model_type => 'Request'
    UserProfileRule.create :user_profile => grantee_profile, :permission_name => 'update_own', :model_type => 'Request'
    UserProfileRule.create :user_profile => grantee_profile, :permission_name => 'delete_own', :model_type => 'Request'
    UserProfileRule.create :user_profile => grantee_profile, :permission_name => 'create_own', :model_type => 'ModelDocument'
    UserProfileRule.create :user_profile => grantee_profile, :permission_name => 'delete', :model_type => 'ModelDocument'
    UserProfileRule.create :user_profile => grantee_profile, :permission_name => 'update_own', :model_type => 'RequestReport'
    UserProfileRule.create :user_profile => grantee_profile, :permission_name => 'listview', :model_type => 'ModelDocument'
  end

  def self.down
    grantee_profile = UserProfile.where(:name => 'Grantee').first
    UserProfileRule.where(:user_profile_id => grantee_profile.object_id, :permission_name => 'create_own', :model_type => 'Request').first.destroy
    UserProfileRule.where(:user_profile_id => grantee_profile.object_id, :permission_name => 'view_own', :model_type => 'Request').first.destroy
    UserProfileRule.where(:user_profile_id => grantee_profile.object_id, :permission_name => 'update_own', :model_type => 'Request').first.destroy
    UserProfileRule.where(:user_profile_id => grantee_profile.object_id, :permission_name => 'delete_own', :model_type => 'Request').first.destroy
    UserProfileRule.where(:user_profile_id => grantee_profile.object_id, :permission_name => 'create_own', :model_type => 'ModelDocument').first.destroy
    UserProfileRule.where(:user_profile_id => grantee_profile.object_id, :permission_name => 'delete', :model_type => 'ModelDocument').first.destroy
    UserProfileRule.where(:user_profile_id => grantee_profile.object_id, :permission_name => 'update_own', :model_type => 'RequestReport').first.destroy
    UserProfileRule.where(:user_profile_id => grantee_profile.object_id, :permission_name => 'listview', :model_type => 'ModelDocument').first.destroy
  end
end