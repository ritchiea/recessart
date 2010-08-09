class FluxxGrantCreateRequestReports < ActiveRecord::Migration
  def self.up
    create_table :request_reports do |t|
      t.timestamps
      t.integer :created_by_id, :updated_by_id, :null => true, :limit => 12
      t.integer :request_id, :approved_by_user_id, :null => true, :limit => 12
      t.string :state
      t.string :report_type, :null => false, :default => 'RequestReport'
      t.integer :evaluation_rating
      t.text :report
      t.datetime :due_at, :null => true
      t.datetime :approved_at, :null => true
      t.integer :locked_by_id, :null => true, :limit => 12
      t.datetime :locked_until, :deleted_at, :null => true
      t.boolean :delta, :null => false, :default => true
    end
    add_index :request_reports, :request_id
    execute "alter table request_reports add constraint request_reports_request_id foreign key (request_id) references requests(id)" unless connection.adapter_name =~ /SQLite/i
  end

  def self.down
    drop_table :request_reports
  end
end