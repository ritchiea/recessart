class FluxxGrantCreateRequestTransactions < ActiveRecord::Migration
  def self.up
    create_table :request_transactions do |t|
      t.timestamps
      t.integer :created_by_id, :updated_by_id, :null => true, :limit => 12
      t.integer :request_id, :null => true, :limit => 12
      t.integer :amount_paid, :amount_due, :null => true, :limit => 12
      t.datetime :due_at, :paid_at, :null => true
      t.string :comment
      t.string :payment_type, :payment_confirmation_number
      t.integer :payment_recorded_by_id, :null => true, :limit => 12
      t.string :state
      t.integer :locked_by_id, :null => true, :limit => 12
      t.datetime :locked_until, :deleted_at, :null => true
      t.boolean :delta, :null => false, :default => true
      t.string :request_document_linked_to, :null => :true
    end
    add_index :request_transactions, :request_id
    add_index :request_transactions, :payment_recorded_by_id
    execute "alter table request_transactions add constraint request_transactions_request_id foreign key (request_id) references requests(id)" unless connection.adapter_name =~ /SQLite/i
    execute "alter table request_transactions add constraint request_transactions_payment_recorded_by_id foreign key (payment_recorded_by_id) references users(id)" unless connection.adapter_name =~ /SQLite/i
  end

  def self.down
    drop_table :request_transactions
  end
end