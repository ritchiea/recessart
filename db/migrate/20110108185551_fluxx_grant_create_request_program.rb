class FluxxGrantCreateRequestProgram < ActiveRecord::Migration
  def self.up
    create_table "request_programs", :force => true do |t|
      t.timestamps
      t.integer :created_by_id, :updated_by_id, :null => true, :limit => 12
      t.integer :request_id, :null => true, :limit => 12
      t.integer :program_id, :null => true, :limit => 12
      t.string :state, :null => :no, :default => 'new'
      t.datetime :approved_at
      t.integer :approved_by_user_id, :null => true, :limit => 12
    end
    
    add_constraint 'request_programs', 'request_programs_created_by_id', 'created_by_id', 'users', 'id'
    add_constraint 'request_programs', 'request_programs_updated_by_id', 'updated_by_id', 'users', 'id'
    add_constraint 'request_programs', 'request_programs_request_id', 'request_id', 'requests', 'id'
    add_constraint 'request_programs', 'request_programs_program_id', 'program_id', 'programs', 'id'

    add_index :request_programs, [:request_id, :program_id], :unique => true
  end

  def self.down
    drop_table "request_programs"
  end
end