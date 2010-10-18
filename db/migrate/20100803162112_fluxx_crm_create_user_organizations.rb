class FluxxCrmCreateUserOrganizations < ActiveRecord::Migration
  def self.up
    create_table(:user_organizations, :id => true) do |t|
      t.timestamps
      t.integer :created_by_id, :updated_by_id, :null => true, :limit => 12
      t.integer :user_id,           :limit => 12
      t.integer :organization_id,   :limit => 12
      t.string  :title,             :limit => 400, :null => true
      t.string  :department,        :limit => 400, :null => true
      t.string  :email,             :limit => 400, :null => true
      t.string  :phone,             :limit => 400, :null => true
      t.datetime :deleted_at,       :null => true
      t.datetime :locked_until,              :null => true
      t.integer :locked_by_id,               :null => true
    end

    add_index :user_organizations, :user_id
    add_index :user_organizations, :organization_id
    add_constraint 'user_organizations', 'user_org_org_id', 'organization_id', 'organizations', 'id'
  end

  def self.down
    remove_foreign_key 'user_organizations', 'users', 'user_org_user_id'
    remove_foreign_key 'user_organizations', 'organizations', 'user_org_org_id'
    drop_table :user_organizations
  end
end
