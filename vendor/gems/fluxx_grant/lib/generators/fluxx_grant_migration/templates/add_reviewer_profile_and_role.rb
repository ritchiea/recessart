class FluxxGrantAddReviewerProfileAndRole < ActiveRecord::Migration
  def self.up
    reviewer_profile = UserProfile.create :name => 'Reviewer'
    UserProfileRule.create :user_profile => reviewer_profile, :permission_name => 'view', :model_type => 'Request'
    UserProfileRule.create :user_profile => reviewer_profile, :permission_name => 'create', :model_type => 'RequestReview'
    UserProfileRule.create :user_profile => reviewer_profile, :permission_name => 'update_own', :model_type => 'RequestReview'
  end

  def self.down
    reviewer_profile = UserProfile.where(:name => 'Reviewer')
    UserProfileRule.where(:user_profile_id => reviewer_profile.object_id, :permission_name => 'view', :model_type => 'Request').first.destroy
    UserProfileRule.where(:user_profile_id => reviewer_profile.object_id, :permission_name => 'create', :model_type => 'RequestReview').first.destroy
    UserProfileRule.where(:user_profile_id => reviewer_profile.object_id, :permission_name => 'update_own', :model_type => 'RequestReview').first.destroy
    reviewer_profile.first.destroy
  end
end