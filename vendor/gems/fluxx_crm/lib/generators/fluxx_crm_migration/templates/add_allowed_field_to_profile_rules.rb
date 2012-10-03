class FluxxCrmAddAllowedFieldToProfileRules < ActiveRecord::Migration
  def self.up
    add_column :user_profile_rules, :allowed, :boolean, :null => false, :default => true # Add a column to say whether this rule is allowed or not allowed
  end

  def self.down
    remove_column :user_profile_rules, :allowed
  end
end
