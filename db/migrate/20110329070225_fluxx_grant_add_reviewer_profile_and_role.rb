class FluxxGrantAddReviewerProfileAndRole < ActiveRecord::Migration
  def self.up
    reviewer_profile = UserProfile.create :name => 'Reviewer'
    UserProfileRule.create :user_profile => reviewer_profile, :permission_name => 'view', :model_type => 'Request'
    UserProfileRule.create :user_profile => reviewer_profile, :permission_name => 'update', :model_type => 'Request'
    Role.create :name => 'Reviewer', :roleable_type => 'Program'
  end

  def self.down
    reviewer_profile = UserProfile.where(:name => 'Reviewer')
    UserProfileRule.where(:user_profile_id => reviewer_profile.object_id, :permission_name => 'view', :model_type => 'Request').first.destroy
    UserProfileRule.where(:user_profile_id => reviewer_profile.object_id, :permission_name => 'update', :model_type => 'Request').first.destroy
    reviewer_profile.first.destroy
    reviewer_role = Role.where(:name => 'Reviewer', :roleable_type => 'Program').first.destroy
  end
end