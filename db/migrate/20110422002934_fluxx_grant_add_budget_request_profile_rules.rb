class FluxxGrantAddBudgetRequestProfileRules < ActiveRecord::Migration
  def self.up
    grantee_profile = UserProfile.where(:name => 'Grantee').first
    UserProfileRule.create :user_profile => grantee_profile, :permission_name => 'create_own', :model_type => 'BudgetRequest'
    UserProfileRule.create :user_profile => grantee_profile, :permission_name => 'view_own', :model_type => 'BudgetRequest'
    UserProfileRule.create :user_profile => grantee_profile, :permission_name => 'update_own', :model_type => 'BudgetRequest'
    UserProfileRule.create :user_profile => grantee_profile, :permission_name => 'delete_own', :model_type => 'BudgetRequest'
  end

  def self.down
    grantee_profile = UserProfile.where(:name => 'Grantee').first
    UserProfileRule.where(:user_profile => grantee_profile, :permission_name => 'create_own', :model_type => 'BudgetRequest').first.destroy
    UserProfileRule.where(:user_profile => grantee_profile, :permission_name => 'view_own', :model_type => 'BudgetRequest').first.destroy
    UserProfileRule.where(:user_profile => grantee_profile, :permission_name => 'update_own', :model_type => 'BudgetRequest').first.destroy
    UserProfileRule.where(:user_profile => grantee_profile, :permission_name => 'delete_own', :model_type => 'BudgetRequest').first.destroy
  end
end