class FluxxGrantMakeProjectSummaryATextField < ActiveRecord::Migration
  def self.up
    change_column :requests, :project_summary, :text
  end

  def self.down
    change_column :requests, :project_summary, :string
  end
end