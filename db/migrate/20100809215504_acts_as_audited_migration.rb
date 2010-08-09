class ActsAsAuditedMigration < ActiveRecord::Migration
  def self.up
    create_table :audits, :force => true do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :auditable_id, :integer
      t.column :auditable_type, :string
      t.column :user_id, :integer
      t.column :user_type, :string
      t.column :username, :string
      t.column :action, :string
      t.column :audit_changes, :text
      t.column :version, :integer, :default => 0
      t.column :comment, :string
    end
    if connection.adapter_name =~ /mysql/i
      execute 'ALTER TABLE audits ADD COLUMN full_model longtext collate utf8_unicode_ci' 
    else
      add_column :audits, :full_model, :text
    end
    add_index :audits, [:auditable_id, :auditable_type], :name => 'auditable_index'
    add_index :audits, [:user_id, :user_type], :name => 'user_index'
    add_index :audits, :created_at  
  end

  def self.down
    drop_table :audits
  end
end
