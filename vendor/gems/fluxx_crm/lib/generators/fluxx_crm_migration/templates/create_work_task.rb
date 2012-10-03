class FluxxCrmCreateWorkTask < ActiveRecord::Migration
  def self.up
    create_table "work_tasks", :force => true do |t|
      t.timestamps
      t.integer :created_by_id, :updated_by_id, :null => true, :limit => 12
      t.string :name
      t.text :task_text
      t.string :taskable_type
      t.integer :taskable_id, :limit => 12
      t.datetime :due_at
      t.integer :task_order   # order in which the task elements are displayed
      t.integer :assigned_user_id, :limit => 12
      t.boolean :task_completed, :default => '0'
      t.datetime :deleted_at,                :null => true
      t.datetime :locked_until,              :null => true
      t.integer :locked_by_id,               :null => true
    end

    add_constraint 'work_tasks', 'work_tasks_created_by_id', 'created_by_id', 'users', 'id'
    add_constraint 'work_tasks', 'work_tasks_updated_by_id', 'updated_by_id', 'users', 'id'
    add_constraint 'work_tasks', 'work_tasks_assigned_user_id', 'assigned_user_id', 'users', 'id'
  end

  def self.down
    drop_table "work_tasks"
  end
end