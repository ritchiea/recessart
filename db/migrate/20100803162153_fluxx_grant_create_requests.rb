class FluxxGrantCreateRequests < ActiveRecord::Migration
  def self.up
    create_table :requests do |t|
      t.timestamps
      t.integer :created_by_id, :updated_by_id, :null => true, :limit => 12
      t.integer :program_organization_id, :fiscal_organization_id, :program_id, :initiative_id, :null => true, :limit => 12

      t.boolean :granted, :renewal_grant, :funding_general_operating_support, :board_authorization_required
      
      t.datetime :request_received_at, :grant_approved_at, :grant_agreement_at, :grant_begins_at, :grant_closed_at, :null => true
      t.integer :amount_requested, :amount_recommended, :null => true, :limit => 12
      t.integer :duration_in_months, :null => true, :limit => 12
      t.string :project_summary
      t.string :base_request_id
      
      t.string :fip_title, :fip_consultant_name
      t.datetime :fip_projected_end_at

      t.datetime :fip_projected_end_at
      
      t.datetime :ierf_start_at
      t.datetime :ierf_proposed_end_at
      t.datetime :ierf_budget_end_at
      t.text :ierf_goals
      t.text :ierf_tactics
      t.text :ierf_probability
      t.text :ierf_due_diligence_overlap
      t.text :ierf_due_diligence_risks
      t.text :ierf_due_diligence_noc4_work
      t.text :ierf_due_diligence_board_review
      t.integer :funds_expended_amount
      t.datetime :funds_expended_at

      t.string :type
      t.string :state
      t.integer :locked_by_id, :null => true, :limit => 12
      t.datetime :locked_until, :deleted_at, :null => true
      t.boolean :delta, :null => false, :default => true
      
      t.integer :program_lead_id, :fiscal_org_owner_id, :grantee_signatory_id, :fiscal_signatory_id, :grantee_org_owner_id, :null => true, :limit => 12
    end

    add_index :requests, :granted
    add_index :requests, :program_organization_id
    add_index :requests, :fiscal_organization_id
    add_index :requests, :program_id
    add_index :requests, :initiative_id
    
    
    execute "alter table requests add constraint requests_program_organization_id foreign key (program_organization_id) references organizations(id)" unless connection.adapter_name =~ /SQLite/i
    execute "alter table requests add constraint requests_fiscal_organization_id foreign key (fiscal_organization_id) references organizations(id)" unless connection.adapter_name =~ /SQLite/i
    execute "alter table requests add constraint requests_program_id foreign key (program_id) references programs(id)" unless connection.adapter_name =~ /SQLite/i
    execute "alter table requests add constraint requests_initiative_id foreign key (initiative_id) references initiatives(id)" unless connection.adapter_name =~ /SQLite/i

    execute "alter table requests add constraint requests_program_lead_id foreign key (program_lead_id) references users(id)" unless connection.adapter_name =~ /SQLite/i
    execute "alter table requests add constraint requests_fiscal_org_owner_id foreign key (fiscal_org_owner_id) references users(id)" unless connection.adapter_name =~ /SQLite/i
    execute "alter table requests add constraint requests_grantee_signatory_id foreign key (grantee_signatory_id) references users(id)" unless connection.adapter_name =~ /SQLite/i
    execute "alter table requests add constraint requests_fiscal_signatory_id foreign key (fiscal_signatory_id) references users(id)" unless connection.adapter_name =~ /SQLite/i
    execute "alter table requests add constraint requests_grantee_org_owner_id foreign key (grantee_org_owner_id) references users(id)" unless connection.adapter_name =~ /SQLite/i
  end

  def self.down
    drop_table :requests
  end
end