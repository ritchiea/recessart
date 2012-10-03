class FluxxCrmCreateBankAccount < ActiveRecord::Migration
  def self.up
    create_table "bank_accounts", :force => true do |t|
      t.timestamps
      t.integer :created_by_id, :updated_by_id, :null => true, :limit => 12
      t.string :bank_name,                  :limit => 255, :null => true
      t.string :account_name,               :limit => 255, :null => true
      t.string :account_number,             :limit => 255, :null => true
      t.string :special_instructions,       :limit => 255, :null => true
      t.string :street_address,             :limit => 255, :null => true
      t.string :street_address2,            :limit => 255, :null => true
      t.string :city,                       :limit => 255, :null => true
      t.integer :geo_state_id,              :limit => 12, :null => true
      t.integer :geo_country_id,            :limit => 12, :null => true
      t.string :postal_code,                :limit => 100, :null => true
      t.string :phone,                      :limit => 100, :null => true
      t.string :fax,                        :limit => 100, :null => true
      t.string :bank_code,                  :limit => 255, :null => true
      t.string :bank_contact_name,          :limit => 255, :null => true
      t.string :bank_contact_phone,         :limit => 255, :null => true
      t.string :domestic_wire_aba_routing,             :limit => 255, :null => true
      t.string :domestic_special_wire_instructions
      t.string :foreign_wire_intermediary_bank_name,   :limit => 255, :null => true
      t.string :foreign_wire_intermediary_bank_swift,  :limit => 255, :null => true
      t.string :foreign_wire_beneficiary_bank_swift,   :limit => 255, :null => true
      t.string :foreign_special_wire_instructions
      t.integer :owner_organization_id,     :limit => 12, :null => true
      t.integer :owner_user_id,             :limit => 12, :null => true
    end

    add_constraint 'bank_accounts', 'bank_accounts_created_by_id', 'created_by_id', 'users', 'id'
    add_constraint 'bank_accounts', 'bank_accounts_updated_by_id', 'updated_by_id', 'users', 'id'
    add_constraint 'bank_accounts', 'bank_accounts_geo_country_id', 'geo_country_id', 'geo_countries', 'id'
    add_constraint 'bank_accounts', 'bank_accounts_geo_state_id', 'geo_state_id', 'geo_states', 'id'
    add_constraint 'bank_accounts', 'bank_accounts_owner_user_id', 'owner_user_id', 'users', 'id'
    add_constraint 'bank_accounts', 'bank_accounts_owner_organization_id', 'owner_organization_id', 'organizations', 'id'
  end

  def self.down
    drop_table "bank_accounts"
  end
end