class FluxxCrmCreateUserProfiles < ActiveRecord::Migration
  def self.up
    create_table :user_profiles do |t|
      t.timestamps
      t.string :name
    end

    add_index :user_profiles, :name
    add_column :users, :user_profile_id, :integer
    add_constraint 'users', 'users_user_profile_id', 'user_profile_id', 'user_profiles', 'id'
  end

  def self.down
    add_column :users, :user_profile_id
    drop_table :user_profiles
  end
end
