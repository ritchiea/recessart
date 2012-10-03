class FluxxCrmCreateUserProfileRules < ActiveRecord::Migration
  def self.up
    create_table :user_profile_rules do |t|
      t.timestamps
      t.integer :user_profile_id
      t.string :role_name
    end

    add_index :user_profile_rules, :role_name
    add_constraint 'user_profile_rules', 'user_profile_rules_user_profile_id', 'user_profile_id', 'user_profiles', 'id'
  end

  def self.down
    drop_table :user_profile_rules
  end
end
