class FluxxGrantAddBankAccountToTransaction < ActiveRecord::Migration
  def self.up
    change_table :request_transactions do |t|
      t.integer :bank_account_id
    end
  end

  def self.down
    change_table :request_transactions do |t|
      t.remove :bank_account_id
    end
  end
end