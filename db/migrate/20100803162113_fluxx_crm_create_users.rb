class FluxxCrmCreateUsers < ActiveRecord::Migration
  def self.up
    create_table "users", :force => true do |t|
      t.timestamps
      t.integer :created_by_id, :updated_by_id, :null => true, :limit => 12
      t.text   :roles_text
      t.string :login,                       :limit => 40, :null => true
      t.string :first_name,                  :limit => 400, :null => true, :default => ''
      t.string :last_name,                   :limit => 400, :null => true, :default => ''
      t.string :email,                       :limit => 250, :null => true
      t.string :personal_email,              :limit => 400, :null => true
      t.string :salutation,                  :limit => 400, :null => true
      t.string :prefix,                      :limit => 400, :null => true
      t.string :middle_initial,              :limit => 400, :null => true
      t.string :personal_phone,              :limit => 400, :null => true
      t.string :personal_mobile,             :limit => 400, :null => true
      t.string :personal_fax,                :limit => 400, :null => true
      t.string :personal_street_address,     :limit => 400, :null => true
      t.string :personal_street_address2,    :limit => 400, :null => true
      t.string :personal_city,               :limit => 400, :null => true
      t.integer :personal_geo_state_id,      :limit => 12, :null => true
      t.integer :personal_geo_country_id,        :limit => 12, :null => true
      t.string :personal_postal_code,        :limit => 400, :null => true
      t.string :work_phone,                  :limit => 400, :null => true
      t.string :work_fax,                    :limit => 400, :null => true
      t.string :other_contact,               :limit => 400, :null => true
      t.string :assistant_name,              :limit => 400, :null => true
      t.string :assistant_phone,             :limit => 400, :null => true
      t.string :assistant_email,             :limit => 400, :null => true
      t.string :blog_url,                    :limit => 2048, :null => true
      t.string :twitter_url,                 :limit => 2048, :null => true
      t.datetime :birth_at,                  :null => true
      t.string :state,                       :null => :no, :default => 'passive'
      t.boolean :delta,                      :null => :false, :default => true
      t.datetime :deleted_at,                :null => true
      t.string :user_salutation,             :limit => 40, :null => true
      t.integer :primary_user_organization_id, :limit => 12, :null => true
      t.datetime :last_logged_in_at,         :null => true
      t.string :time_zone,                   :limit => 40, :null => :false, :default => (ActiveSupport::TimeZone.us_zones.select{|tz| tz.utc_offset == -28800}).first.name
      t.datetime :locked_until,              :null => true
      t.integer :locked_by_id,               :null => true
    end
    add_index :users, :login, :unique => true
    add_index :users, :email, :unique => true
    
    add_constraint 'users', 'users_personal_country_id', 'personal_geo_country_id', 'geo_countries', 'id'
    add_constraint 'users', 'users_personal_geo_state_id', 'personal_geo_state_id', 'geo_states', 'id'
    add_constraint 'users', 'users_primary_user_org_id', 'primary_user_organization_id', 'user_organizations', 'id'

    add_constraint 'user_organizations', 'user_org_user_id', 'user_id', 'users', 'id'
    add_constraint 'user_organizations', 'user_organizations_created_by_id', 'created_by_id', 'users', 'id'
    add_constraint 'user_organizations', 'user_organizations_updated_by_id', 'updated_by_id', 'users', 'id'

    add_constraint 'organizations', 'organizations_created_by_id', 'created_by_id', 'users', 'id'
    add_constraint 'organizations', 'organizations_updated_by_id', 'updated_by_id', 'users', 'id'
  end

  def self.down
    drop_table "users"
  end
end
