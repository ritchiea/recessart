class FluxxCrmAddWorktaskCompletedAtDate < ActiveRecord::Migration
  def self.up
    change_table :work_tasks do |t|
      t.datetime :completed_at
    end
  end

  def self.down
    change_table :work_tasks do |t|
      t.remove :completed_at
    end
  end
end