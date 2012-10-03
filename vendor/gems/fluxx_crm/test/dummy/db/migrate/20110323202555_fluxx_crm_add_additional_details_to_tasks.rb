class FluxxCrmAddAdditionalDetailsToTasks < ActiveRecord::Migration
  def self.up
    return
    change_table :work_tasks do |t|
      t.text :additional_details
    end
  end

  def self.down
    change_table :work_tasks do |t|
      t.remove :additional_details
    end
  end
end