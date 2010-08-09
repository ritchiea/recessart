class FluxxCrmCreateOrganizations < ActiveRecord::Migration
  def self.up
    create_table :organizations do |t|
      t.timestamps
      t.integer :created_by_id, :updated_by_id, :null => true, :limit => 12
      t.string :name,                       :limit => 1000, :null => false
      t.string :street_address,             :limit => 255, :null => true
      t.string :street_address2,            :limit => 255, :null => true
      t.string :city,                       :limit => 100, :null => true
      t.integer :geo_state_id,              :limit => 12, :null => true
      t.integer :geo_country_id,                :limit => 12, :null => true
      t.string :postal_code,                :limit => 100, :null => true
      t.string :phone,                      :limit => 100, :null => true
      t.string :other_contact,              :limit => 100, :null => true
      t.string :fax,                        :limit => 100, :null => true
      t.string :email,                      :limit => 100, :null => true
      t.string :url,                        :limit => 2048, :null => true
      t.string :blog_url,                   :limit => 2048, :null => true
      t.string :twitter_url,                :limit => 2048, :null => true
      t.string :acronym,                    :limit => 100, :null => true
      t.string :state, :null => :no, :default => 'new'
      t.boolean :delta,                      :null => :false, :default => true
      t.datetime :deleted_at,                :null => true
      t.integer :parent_org_id,                :limit => 12, :null => true
      t.datetime :locked_until,              :null => true
      t.integer :locked_by_id,               :null => true
    end
    add_index :organizations, :name, :unique => false
    add_index :organizations, :parent_org_id, :unique => false
    execute "alter table organizations add constraint organizations_geo_country_id foreign key (geo_country_id) references geo_countries(id)" unless connection.adapter_name =~ /SQLite/i
    execute "alter table organizations add constraint organizations_geo_state_id foreign key (geo_state_id) references geo_states(id)" unless connection.adapter_name =~ /SQLite/i
    execute "alter table organizations add constraint organizations_parent_org_id foreign key (parent_org_id) references organizations(id)" unless connection.adapter_name =~ /SQLite/i
  end

  def self.down
    drop_table :organizations
  end
end
