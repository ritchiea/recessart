class FluxxGrantCreateLoi < ActiveRecord::Migration
  def self.up
        create_table "lois", :force => true do |t|
    t.timestamps
    t.integer :created_by_id, :updated_by_id, :null => true, :limit => 12
    t.string :application, :organization, :project_title, :project_summary
    t.string :address, :null => true
    t.integer :program_id, :null => true, :limit => 12
    t.datetime :locked_until, :deleted_at, :null => true
  end

  add_constraint 'lois', 'lois_created_by_id', 'created_by_id', 'users', 'id'
  add_constraint 'lois', 'lois_updated_by_id', 'updated_by_id', 'users', 'id'
  end

  def self.down
    drop_table "lois"
  end
end