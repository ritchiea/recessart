class FluxxGrantAddPayeeToRequestTransaction < ActiveRecord::Migration
  def self.up
    add_column :request_transactions, :organization_payee_id, :integer
    add_column :request_transactions, :user_payee_id, :integer
    add_constraint 'request_transactions', 'request_transactions_org_payee_id', 'organization_payee_id', 'organizations', 'id'
    add_constraint 'request_transactions', 'request_transactions_user_payee_id', 'user_payee_id', 'users', 'id'
  end

  def self.down
    remove_constraint 'request_transactions', 'request_transactions_user_payee_id'
    remove_constraint 'request_transactions', 'request_transactions_org_payee_id'
    remove_column :request_transactions, :user_payee_id
    remove_column :request_transactions, :organization_payee_id
  end
end